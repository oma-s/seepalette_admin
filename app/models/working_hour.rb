# == Schema Information
#
# Table name: working_hours
#
#  id               :integer          not null, primary key
#  break_minutes    :integer
#  date             :date
#  duration_minutes :integer
#  end_at           :datetime
#  start_at         :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer          not null
#
# Indexes
#
#  index_working_hours_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#

class WorkingHour < ApplicationRecord
  belongs_to :user

  before_validation :calculate_duration
  before_validation :extract_date_from_start_at

  validates :date, :start_at, :end_at, :break_minutes, presence: true
  validates :break_minutes, numericality: {greater_than_or_equal_to: 0}
  validate :end_time_after_start_time

  private

  def calculate_duration
    total_minutes = ((end_at - start_at) / 60).to_i - break_minutes
    self.duration_minutes = [total_minutes, 0].max
  end

  def extract_date_from_start_at
    self.date = start_at.to_date if date.blank? && start_at.present?
  end

  def end_time_after_start_time
    return if end_at > start_at

    errors.add(:end_at, "must be after start time")
  end
end
