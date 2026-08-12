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

  scope :chronological, -> { order(start_at: :asc, end_at: :asc) }

  before_validation :calculate_duration
  before_validation :extract_date_from_start_at

  validates :date, :start_at, :end_at, :break_minutes, presence: true
  validates :break_minutes, numericality: {greater_than_or_equal_to: 0}
  validate :end_time_after_start_time
  validate :end_time_may_not_be_in_the_future
  validate :break_may_not_exceed_elapsed_time
  validate :does_not_overlap_another_entry

  private

  def calculate_duration
    return if start_at.blank? || end_at.blank? || break_minutes.blank?

    total_minutes = ((end_at - start_at) / 60).to_i - break_minutes
    self.duration_minutes = [total_minutes, 0].max
  end

  def extract_date_from_start_at
    self.date = start_at.to_date if date.blank? && start_at.present?
  end

  def end_time_after_start_time
    return if start_at.blank? || end_at.blank? || end_at > start_at

    errors.add(:end_at, "must be after start time")
  end

  def end_time_may_not_be_in_the_future
    return if end_at.blank? || end_at <= Time.current

    errors.add(:end_at, "darf nicht in der Zukunft liegen")
  end

  def break_may_not_exceed_elapsed_time
    return if start_at.blank? || end_at.blank? || break_minutes.blank? || end_at <= start_at
    return if break_minutes <= ((end_at - start_at) / 60).to_i

    errors.add(:break_minutes, "darf nicht länger als die Anwesenheit sein")
  end

  def does_not_overlap_another_entry
    return if user_id.blank? || start_at.blank? || end_at.blank? || end_at <= start_at

    overlap = self.class.where(user_id: user_id).where.not(id: id)
      .where("start_at < ? AND end_at > ?", end_at, start_at).exists?
    errors.add(:base, "Die Arbeitszeit überschneidet sich mit einem vorhandenen Eintrag") if overlap
  end
end
