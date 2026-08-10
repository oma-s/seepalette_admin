# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkShift, type: :model do
  it "calculates its planned duration after the break" do
    shift = build(:work_shift, break_minutes: 30)

    expect(shift.duration_minutes).to eq(450)
  end

  it "rejects an end time before its start time" do
    shift = build(:work_shift)
    shift.ends_at = shift.starts_at

    expect(shift).not_to be_valid
    expect(shift.errors[:ends_at]).to include("must be after the start time")
  end

  it "rejects a break as long as the whole shift" do
    shift = build(:work_shift, break_minutes: 8.hours.in_minutes)

    expect(shift).not_to be_valid
    expect(shift.errors[:break_minutes]).to include("must be shorter than the shift")
  end

  it "rejects a shift starting on a different schedule day" do
    shift = build(:work_shift)
    shift.starts_at += 1.day
    shift.ends_at += 1.day

    expect(shift).not_to be_valid
    expect(shift.errors[:starts_at]).to include("must be on the schedule day")
  end

  it "rejects overlapping persisted shifts for the same user" do
    existing_shift = create(:work_shift)
    overlapping_shift = build(
      :work_shift,
      work_schedule_day: existing_shift.work_schedule_day,
      user: existing_shift.user,
      starts_at: existing_shift.starts_at + 1.hour,
      ends_at: existing_shift.ends_at + 1.hour
    )

    expect(overlapping_shift).not_to be_valid
    expect(overlapping_shift.errors[:base]).to include("overlaps another shift for this user")
  end

  it "allows adjacent shifts for the same user" do
    existing_shift = create(:work_shift)
    adjacent_shift = build(
      :work_shift,
      work_schedule_day: existing_shift.work_schedule_day,
      user: existing_shift.user,
      starts_at: existing_shift.ends_at,
      ends_at: existing_shift.ends_at + 2.hours
    )

    expect(adjacent_shift).to be_valid
  end
end
