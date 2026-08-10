# frozen_string_literal: true

# == Schema Information
#
# Table name: work_schedule_day_stations
#
#  id                   :integer          not null, primary key
#  name                 :string           not null
#  position             :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  station_id           :integer
#  work_schedule_day_id :integer          not null
#
# Indexes
#
#  idx_day_stations_unique_catalog_station                   (work_schedule_day_id,station_id) UNIQUE WHERE station_id IS NOT NULL
#  idx_day_stations_unique_name                              (work_schedule_day_id,name) UNIQUE
#  index_work_schedule_day_stations_on_station_id            (station_id)
#  index_work_schedule_day_stations_on_work_schedule_day_id  (work_schedule_day_id)
#
# Foreign Keys
#
#  station_id            (station_id => stations.id)
#  work_schedule_day_id  (work_schedule_day_id => work_schedule_days.id)
#
class WorkScheduleDayStation < ApplicationRecord
  belongs_to :work_schedule_day, inverse_of: :work_schedule_day_stations
  belongs_to :station, optional: true
  has_many :work_shifts, -> { chronological }, dependent: :destroy, inverse_of: :work_schedule_day_station

  validates :name, presence: true, uniqueness: {scope: :work_schedule_day_id, case_sensitive: false}
  validates :station_id, uniqueness: {scope: :work_schedule_day_id}, allow_nil: true
  validates :position, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  after_destroy :touch_schedule_content
  after_save :touch_schedule_content

  def planner_payload
    {
      id: id,
      station_id: station_id,
      name: name,
      position: position,
      shifts: work_shifts.map(&:planner_payload)
    }
  end

  def publication_payload
    planner_payload.except(:id).merge(
      shifts: work_shifts.map do |shift|
        shift.planner_payload.except(:id).merge(user_id: shift.user_id)
      end
    )
  end

  private

  def touch_schedule_content
    work_schedule_day.work_schedule.touch_content!
  end
end
