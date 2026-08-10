# frozen_string_literal: true

# == Schema Information
#
# Table name: work_schedule_days
#
#  id                :integer          not null, primary key
#  date              :date             not null
#  grid_end_minute   :integer          default(1440), not null
#  grid_start_minute :integer          default(420), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  work_schedule_id  :integer          not null
#
# Indexes
#
#  index_work_schedule_days_on_work_schedule_id           (work_schedule_id)
#  index_work_schedule_days_on_work_schedule_id_and_date  (work_schedule_id,date) UNIQUE
#
# Foreign Keys
#
#  work_schedule_id  (work_schedule_id => work_schedules.id)
#
class WorkScheduleDay < ApplicationRecord
  DEFAULT_GRID_START = 7 * 60
  DEFAULT_GRID_END = 24 * 60

  belongs_to :work_schedule, inverse_of: :work_schedule_days
  has_many :work_schedule_day_stations, -> { order(:position, :name) }, dependent: :destroy, inverse_of: :work_schedule_day
  has_many :work_shifts, through: :work_schedule_day_stations
  has_many :day_notices, -> { display_order }, dependent: :destroy, inverse_of: :work_schedule_day

  validates :date, presence: true, uniqueness: {scope: :work_schedule_id}
  validates :grid_start_minute, :grid_end_minute, numericality: {only_integer: true}
  validate :date_is_within_schedule
  validate :valid_grid_window

  after_create :add_default_stations!
  after_destroy :touch_schedule_content
  after_save :touch_schedule_content, unless: :previously_new_record?

  def to_s
    I18n.l(date)
  end

  def add_catalog_station!(station)
    work_schedule_day_stations.find_or_create_by!(station: station) do |day_station|
      day_station.name = station.name
      day_station.position = station.position
    end
  end

  def add_custom_station!(name)
    next_position = work_schedule_day_stations.maximum(:position).to_i + 1
    work_schedule_day_stations.create!(name: name, position: next_position)
  end

  def copy_from!(source, include_stations:, include_notices:, include_shifts:)
    transaction do
      station_map = {}
      if include_stations || include_shifts
        source.work_schedule_day_stations.each do |source_station|
          target_station = if source_station.station
            add_catalog_station!(source_station.station)
          else
            work_schedule_day_stations.find_or_create_by!(name: source_station.name) { |item| item.position = source_station.position }
          end
          station_map[source_station.id] = target_station
        end
      end

      if include_notices
        source.day_notices.each do |notice|
          day_notices.create!(text: notice.text, severity: notice.severity)
        end
      end

      if include_shifts
        day_offset = date - source.date
        source.work_schedule_day_stations.each do |source_station|
          source_station.work_shifts.each do |shift|
            station_map.fetch(source_station.id).work_shifts.create!(
              user: shift.user,
              starts_at: shift.starts_at + day_offset.days,
              ends_at: shift.ends_at + day_offset.days,
              notes: shift.notes
            )
          end
        end
      end
    end
  end

  def planner_payload
    {
      id: id,
      date: date.iso8601,
      label: "#{%w[So Mo Di Mi Do Fr Sa][date.wday]}, #{date.strftime("%d.%m.")}",
      grid_start_minute: grid_start_minute,
      grid_end_minute: grid_end_minute,
      notices: day_notices.map { |notice| notice_payload(notice).merge(id: notice.id) },
      stations: work_schedule_day_stations.map(&:planner_payload)
    }
  end

  def publication_payload
    planner_payload.except(:id, :label).merge(
      stations: work_schedule_day_stations.map(&:publication_payload),
      notices: day_notices.map { |notice| notice_payload(notice) }
    )
  end

  private

  def notice_payload(notice)
    {text: notice.text, severity: notice.severity, created_at: notice.created_at.iso8601}
  end

  def add_default_stations!
    Station.ensure_defaults!
    Station.active.defaults.ordered.each { |station| add_catalog_station!(station) }
  end

  def date_is_within_schedule
    return if date.blank? || work_schedule.blank?
    return if date.between?(work_schedule.starts_on, work_schedule.ends_on)

    errors.add(:date, "muss im Dienstplanzeitraum liegen")
  end

  def valid_grid_window
    return if grid_start_minute.blank? || grid_end_minute.blank?
    errors.add(:grid_start_minute, "muss zwischen 00:00 und 23:45 liegen") unless grid_start_minute.between?(0, 1_425)
    errors.add(:grid_end_minute, "muss nach dem Start und spätestens am Ende des Folgetags liegen") unless grid_end_minute.between?(grid_start_minute + 15, 2_880)
    errors.add(:base, "Zeiten müssen auf 15 Minuten liegen") unless (grid_start_minute % 15).zero? && (grid_end_minute % 15).zero?
  end

  def touch_schedule_content
    work_schedule&.touch_content!
  end
end
