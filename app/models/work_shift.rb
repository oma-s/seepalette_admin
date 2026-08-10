# frozen_string_literal: true

# == Schema Information
#
# Table name: work_shifts
#
#  id                   :integer          not null, primary key
#  break_minutes        :integer          default(0), not null
#  ends_at              :datetime         not null
#  notes                :text
#  position             :string           not null
#  starts_at            :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer          not null
#  work_schedule_day_id :integer          not null
#
# Indexes
#
#  index_work_shifts_on_user_id                             (user_id)
#  index_work_shifts_on_user_id_and_starts_at_and_ends_at   (user_id,starts_at,ends_at)
#  index_work_shifts_on_work_schedule_day_id                (work_schedule_day_id)
#  index_work_shifts_on_work_schedule_day_id_and_starts_at  (work_schedule_day_id,starts_at)
#
# Foreign Keys
#
#  user_id               (user_id => users.id)
#  work_schedule_day_id  (work_schedule_day_id => work_schedule_days.id)
#
class WorkShift < ApplicationRecord
  belongs_to :work_schedule_day, inverse_of: :work_shifts
  belongs_to :user

  delegate :work_schedule, to: :work_schedule_day

  scope :chronological, -> { order(:starts_at, :position) }

  validates :position, :starts_at, :ends_at, presence: true
  validates :break_minutes, numericality: {greater_than_or_equal_to: 0, only_integer: true}
  validate :ends_after_it_starts
  validate :starts_on_schedule_day
  validate :break_fits_within_shift
  validate :does_not_overlap_another_shift

  def duration_minutes
    return unless starts_at && ends_at

    [((ends_at - starts_at) / 60).to_i - break_minutes.to_i, 0].max
  end

  def to_s
    "#{user} - #{position}"
  end

  private

  def ends_after_it_starts
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "must be after the start time")
  end

  def starts_on_schedule_day
    return if starts_at.blank? || work_schedule_day.blank? || work_schedule_day.date.blank?
    return if starts_at.to_date == work_schedule_day.date

    errors.add(:starts_at, "must be on the schedule day")
  end

  def break_fits_within_shift
    return if starts_at.blank? || ends_at.blank? || ends_at <= starts_at || break_minutes.blank?
    return if break_minutes < ((ends_at - starts_at) / 60).to_i

    errors.add(:break_minutes, "must be shorter than the shift")
  end

  def does_not_overlap_another_shift
    return if user_id.blank? || starts_at.blank? || ends_at.blank? || ends_at <= starts_at

    overlap = self.class
      .where(user_id: user_id)
      .where.not(id: id)
      .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
      .exists?

    errors.add(:base, "overlaps another shift for this user") if overlap
  end
end
