# frozen_string_literal: true

# == Schema Information
#
# Table name: work_shifts
#
#  id                           :integer          not null, primary key
#  ends_at                      :datetime         not null
#  notes                        :text
#  starts_at                    :datetime         not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_id                      :integer          not null
#  work_schedule_day_station_id :integer          not null
#
# Indexes
#
#  idx_work_shifts_on_day_station                          (work_schedule_day_station_id)
#  idx_work_shifts_station_start                           (work_schedule_day_station_id,starts_at)
#  index_work_shifts_on_user_id                            (user_id)
#  index_work_shifts_on_user_id_and_starts_at_and_ends_at  (user_id,starts_at,ends_at)
#
# Foreign Keys
#
#  user_id                       (user_id => users.id)
#  work_schedule_day_station_id  (work_schedule_day_station_id => work_schedule_day_stations.id)
#
class WorkShift < ApplicationRecord
  belongs_to :work_schedule_day_station, inverse_of: :work_shifts
  belongs_to :user

  delegate :work_schedule_day, :name, to: :work_schedule_day_station
  delegate :work_schedule, to: :work_schedule_day

  scope :chronological, -> { order(:starts_at, :ends_at) }

  validates :starts_at, :ends_at, presence: true
  validate :ends_after_it_starts
  validate :starts_on_schedule_day
  validate :duration_is_less_than_one_day
  validate :times_are_quarter_hour_aligned
  validate :user_is_available
  validate :station_is_available

  after_destroy :touch_schedule_content
  after_save :expand_day_grid!
  after_save :touch_schedule_content

  def duration_minutes
    return unless starts_at && ends_at

    ((ends_at - starts_at) / 60).to_i
  end

  def overnight?
    starts_at.to_date != ends_at.to_date
  end

  def to_s
    "#{user} – #{name}"
  end

  def planner_payload
    day_date = work_schedule_day.date
    {
      id: id,
      user_id: user_id,
      user_name: user.to_s,
      user_color: user.schedule_color,
      starts_at: starts_at.iso8601,
      ends_at: ends_at.iso8601,
      start_time: starts_at.strftime("%H:%M"),
      end_time: ends_at.strftime("%H:%M"),
      start_minute: ((starts_at.to_date - day_date).to_i * 1_440) + (starts_at.hour * 60) + starts_at.min,
      end_minute: ((ends_at.to_date - day_date).to_i * 1_440) + (ends_at.hour * 60) + ends_at.min,
      overnight: overnight?,
      notes: notes
    }
  end

  private

  def ends_after_it_starts
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "muss nach dem Start liegen")
  end

  def starts_on_schedule_day
    return if starts_at.blank? || work_schedule_day.blank? || starts_at.to_date == work_schedule_day.date

    errors.add(:starts_at, "muss am ausgewählten Tag beginnen")
  end

  def duration_is_less_than_one_day
    return if starts_at.blank? || ends_at.blank? || ends_at <= starts_at
    return if ends_at - starts_at < 24.hours

    errors.add(:ends_at, "muss weniger als 24 Stunden nach dem Start liegen")
  end

  def times_are_quarter_hour_aligned
    return if starts_at.blank? || ends_at.blank?
    return if [starts_at, ends_at].all? { |time| (time.min % 15).zero? && time.sec.zero? }

    errors.add(:base, "Start und Ende müssen auf 15 Minuten liegen")
  end

  def user_is_available
    return if user_id.blank? || starts_at.blank? || ends_at.blank? || ends_at <= starts_at

    overlap = self.class.where(user_id: user_id).where.not(id: id)
      .where("starts_at < ? AND ends_at > ?", ends_at, starts_at).exists?
    errors.add(:user, "hat in diesem Zeitraum bereits eine Schicht") if overlap
  end

  def station_is_available
    return if work_schedule_day_station.blank? || starts_at.blank? || ends_at.blank? || ends_at <= starts_at

    station_scope = if work_schedule_day_station.station_id
      self.class.joins(:work_schedule_day_station)
        .where(work_schedule_day_stations: {station_id: work_schedule_day_station.station_id})
    else
      self.class.where(work_schedule_day_station_id: work_schedule_day_station_id)
    end
    overlap = station_scope.where.not(id: id).where("starts_at < ? AND ends_at > ?", ends_at, starts_at).exists?
    errors.add(:work_schedule_day_station, "ist in diesem Zeitraum bereits besetzt") if overlap
  end

  def expand_day_grid!
    day = work_schedule_day
    start_minute = starts_at.hour * 60 + starts_at.min
    end_minute = ((ends_at.to_date - day.date).to_i * 1_440) + ends_at.hour * 60 + ends_at.min
    changes = {}
    changes[:grid_start_minute] = start_minute if start_minute < day.grid_start_minute
    changes[:grid_end_minute] = end_minute if end_minute > day.grid_end_minute
    day.update!(changes) if changes.any?
  end

  def touch_schedule_content
    work_schedule&.touch_content!
  end
end
