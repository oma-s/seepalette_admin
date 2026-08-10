# frozen_string_literal: true

# == Schema Information
#
# Table name: day_notices
#
#  id                   :integer          not null, primary key
#  severity             :string           default("info"), not null
#  text                 :text             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  work_schedule_day_id :integer          not null
#
# Indexes
#
#  index_day_notices_on_work_schedule_day_id  (work_schedule_day_id)
#
# Foreign Keys
#
#  work_schedule_day_id  (work_schedule_day_id => work_schedule_days.id)
#
class DayNotice < ApplicationRecord
  SEVERITIES = %w[info warning critical].freeze

  belongs_to :work_schedule_day, inverse_of: :day_notices

  validates :text, presence: true
  validates :severity, inclusion: {in: SEVERITIES}

  scope :display_order, -> {
    order(Arel.sql("CASE severity WHEN 'critical' THEN 0 WHEN 'warning' THEN 1 ELSE 2 END"), :created_at, :id)
  }

  after_destroy :touch_schedule_content
  after_save :touch_schedule_content

  private

  def touch_schedule_content
    work_schedule_day.work_schedule.touch_content!
  end
end
