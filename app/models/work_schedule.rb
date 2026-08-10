# frozen_string_literal: true

# == Schema Information
#
# Table name: work_schedules
#
#  id                 :integer          not null, primary key
#  content_updated_at :datetime         not null
#  ends_on            :date             not null
#  notes              :text
#  starts_on          :date             not null
#  title              :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_work_schedules_on_starts_on_and_ends_on  (starts_on,ends_on)
#
class WorkSchedule < ApplicationRecord
  has_many :work_schedule_days, -> { order(:date) }, dependent: :destroy, inverse_of: :work_schedule
  has_many :work_schedule_publications, -> { order(:revision) }, dependent: :restrict_with_error, inverse_of: :work_schedule
  has_many :work_schedule_day_stations, through: :work_schedule_days
  has_many :work_shifts, through: :work_schedule_day_stations

  validates :title, :starts_on, :ends_on, :content_updated_at, presence: true
  validate :ends_on_or_after_starts_on
  validate :removed_days_are_empty, if: :date_range_changed?

  before_validation :initialize_content_updated_at, on: :create
  after_create :create_schedule_days!
  before_update :mark_direct_content_change, if: :direct_content_changed?
  after_update :sync_schedule_days!, if: :saved_date_range_change?

  def to_s
    title
  end

  def latest_publication
    work_schedule_publications.last
  end

  def publication_state
    publication = latest_publication
    return :draft unless publication
    return :published if publication.source_updated_at >= content_updated_at

    :changes_pending
  end

  def publish!(user)
    raise ActiveRecord::RecordInvalid, self if work_shifts.none?

    with_lock do
      publication = work_schedule_publications.create!(
        published_by: user,
        revision: work_schedule_publications.maximum(:revision).to_i + 1,
        source_updated_at: content_updated_at,
        published_at: Time.current,
        payload: publication_payload
      )
      publication
    end
  end

  def duplicate_to!(new_start_date, include_stations: true, include_notices: true, include_shifts: true)
    new_start_date = Date.parse(new_start_date.to_s)
    offset = new_start_date - starts_on
    self.class.transaction do
      duplicate = self.class.create!(
        title: "#{title} (Kopie)",
        starts_on: new_start_date,
        ends_on: ends_on + offset,
        notes: notes
      )

      work_schedule_days.includes(:day_notices, work_schedule_day_stations: {work_shifts: :user}).to_a.each do |source_day|
        target_day = duplicate.work_schedule_days.find_by!(date: source_day.date + offset)
        target_day.copy_from!(source_day,
          include_stations: include_stations,
          include_notices: include_notices,
          include_shifts: include_shifts)
      end
      duplicate
    end
  end

  def publication_payload
    {
      id: id,
      title: title,
      starts_on: starts_on.iso8601,
      ends_on: ends_on.iso8601,
      notes: notes,
      days: work_schedule_days.includes(:day_notices, work_schedule_day_stations: {work_shifts: :user}).map(&:publication_payload)
    }
  end

  def planner_payload
    {
      id: id,
      title: title,
      starts_on: starts_on.iso8601,
      ends_on: ends_on.iso8601,
      notes: notes,
      publication_state: publication_state,
      latest_revision: latest_publication&.revision,
      days: work_schedule_days.includes(:day_notices, work_schedule_day_stations: {work_shifts: :user}).map(&:planner_payload),
      users: User.schedulable.order(:given_name, :family_name).map { |user| {id: user.id, name: user.to_s, color: user.schedule_color} },
      stations: Station.active.ordered.map { |station| {id: station.id, name: station.name, default_enabled: station.default_enabled} }
    }
  end

  def touch_content!
    update_column(:content_updated_at, Time.current)
  end

  private

  def initialize_content_updated_at
    self.content_updated_at ||= Time.current
  end

  def ends_on_or_after_starts_on
    return if starts_on.blank? || ends_on.blank? || ends_on >= starts_on

    errors.add(:ends_on, "muss am oder nach dem Startdatum liegen")
  end

  def date_range_changed?
    will_save_change_to_starts_on? || will_save_change_to_ends_on?
  end

  def saved_date_range_change?
    saved_change_to_starts_on? || saved_change_to_ends_on?
  end

  def direct_content_changed?
    will_save_change_to_title? || will_save_change_to_starts_on? || will_save_change_to_ends_on? || will_save_change_to_notes?
  end

  def mark_direct_content_change
    self.content_updated_at = Time.current
  end

  def removed_days_are_empty
    return if starts_on.blank? || ends_on.blank?

    removed = work_schedule_days.reject { |day| day.date.between?(starts_on, ends_on) }
    return if removed.none? { |day| day.work_shifts.exists? || day.day_notices.exists? }

    errors.add(:base, "Der Zeitraum kann nicht verkürzt werden, solange entfernte Tage Schichten oder Hinweise enthalten")
  end

  def create_schedule_days!
    sync_schedule_days!
  end

  def sync_schedule_days!
    desired_dates = (starts_on..ends_on).to_a
    existing_dates = work_schedule_days.pluck(:date)
    (desired_dates - existing_dates).each { |date| work_schedule_days.create!(date: date) }
    work_schedule_days.where.not(date: desired_dates).destroy_all
  end
end
