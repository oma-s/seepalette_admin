# frozen_string_literal: true

# == Schema Information
#
# Table name: work_schedules
#
#  id         :integer          not null, primary key
#  ends_on    :date             not null
#  notes      :text
#  starts_on  :date             not null
#  status     :integer          default(0), not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_work_schedules_on_starts_on_and_ends_on  (starts_on,ends_on)
#  index_work_schedules_on_status                 (status)
#
class WorkSchedule < ApplicationRecord
  has_many :work_schedule_days, -> { order(:date) }, dependent: :destroy, inverse_of: :work_schedule
  has_many :work_shifts, through: :work_schedule_days

  accepts_nested_attributes_for :work_schedule_days, allow_destroy: true

  enum :status, {draft: 0, published: 1}, default: :draft

  validates :title, :starts_on, :ends_on, :status, presence: true
  validate :ends_on_or_after_starts_on
  validate :published_schedule_has_days

  def to_s
    title
  end

  private

  def ends_on_or_after_starts_on
    return if starts_on.blank? || ends_on.blank? || ends_on >= starts_on

    errors.add(:ends_on, "must be on or after the start date")
  end

  def published_schedule_has_days
    return unless published?
    return if work_schedule_days.reject(&:marked_for_destruction?).any?

    errors.add(:status, "can only be published when the schedule has at least one day")
  end
end
