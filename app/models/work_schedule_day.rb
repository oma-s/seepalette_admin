# frozen_string_literal: true

# == Schema Information
#
# Table name: work_schedule_days
#
#  id               :integer          not null, primary key
#  date             :date             not null
#  notes            :text
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  work_schedule_id :integer          not null
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
  belongs_to :work_schedule, inverse_of: :work_schedule_days
  has_many :work_shifts, -> { order(:starts_at, :position) }, dependent: :destroy, inverse_of: :work_schedule_day

  accepts_nested_attributes_for :work_shifts, allow_destroy: true

  validates :date, presence: true, uniqueness: {scope: :work_schedule_id}
  validate :date_is_within_schedule
  validate :nested_shifts_do_not_overlap

  def to_s
    [date&.strftime("%d.%m.%Y"), title].compact_blank.join(" - ")
  end

  private

  def date_is_within_schedule
    return if date.blank? || work_schedule.blank?
    return if work_schedule.starts_on.blank? || work_schedule.ends_on.blank?
    return if date.between?(work_schedule.starts_on, work_schedule.ends_on)

    errors.add(:date, "must be within the schedule date range")
  end

  def nested_shifts_do_not_overlap
    active_shifts = work_shifts.reject(&:marked_for_destruction?).select do |shift|
      shift.user.present? && shift.starts_at.present? && shift.ends_at.present?
    end

    active_shifts.group_by { |shift| shift.user_id || shift.user.object_id }.each_value do |user_shifts|
      user_shifts.combination(2).each do |first_shift, second_shift|
        next unless first_shift.starts_at < second_shift.ends_at && second_shift.starts_at < first_shift.ends_at

        first_shift.errors.add(:base, "overlaps another shift for this user")
        second_shift.errors.add(:base, "overlaps another shift for this user")
        errors.add(:base, "contains overlapping shifts for the same user")
      end
    end
  end
end
