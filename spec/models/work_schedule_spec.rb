# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkSchedule, type: :model do
  it "is valid for an ordered date range" do
    expect(build(:work_schedule)).to be_valid
  end

  it "rejects an end date before the start date" do
    schedule = build(:work_schedule, starts_on: Date.new(2026, 8, 9), ends_on: Date.new(2026, 8, 7))

    expect(schedule).not_to be_valid
    expect(schedule.errors[:ends_on]).to include("must be on or after the start date")
  end

  it "requires at least one day before publication" do
    schedule = build(:work_schedule, status: :published)

    expect(schedule).not_to be_valid
    expect(schedule.errors[:status]).to include("can only be published when the schedule has at least one day")
  end

  it "can publish a schedule with a day" do
    schedule = build(:work_schedule, status: :published)
    schedule.work_schedule_days.build(date: schedule.starts_on)

    expect(schedule).to be_valid
  end
end
