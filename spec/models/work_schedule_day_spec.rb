# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkScheduleDay, type: :model do
  it "is valid within its schedule period" do
    schedule = build(:work_schedule)
    day = build(:work_schedule_day, work_schedule: schedule, date: schedule.starts_on + 1.day)

    expect(day).to be_valid
  end

  it "rejects a date outside its schedule period" do
    schedule = build(:work_schedule)
    day = build(:work_schedule_day, work_schedule: schedule, date: schedule.ends_on + 1.day)

    expect(day).not_to be_valid
    expect(day.errors[:date]).to include("must be within the schedule date range")
  end

  it "rejects overlapping nested shifts for the same user" do
    day = build(:work_schedule_day)
    user = build(:user)
    day.work_shifts.build(
      user: user,
      position: "Bar",
      starts_at: day.date.in_time_zone.change(hour: 10),
      ends_at: day.date.in_time_zone.change(hour: 16)
    )
    day.work_shifts.build(
      user: user,
      position: "Runner",
      starts_at: day.date.in_time_zone.change(hour: 15),
      ends_at: day.date.in_time_zone.change(hour: 18)
    )

    expect(day).not_to be_valid
    expect(day.errors[:base]).to include("contains overlapping shifts for the same user")
  end
end
