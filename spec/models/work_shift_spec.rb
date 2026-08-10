# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkShift, type: :model do
  it "calculates its planned duration" do
    shift = build(:work_shift)

    expect(shift.duration_minutes).to eq(480)
  end

  it "allows a quarter-hour aligned overnight shift" do
    day_station = create(:work_schedule).work_schedule_days.first.work_schedule_day_stations.first
    shift = build(:work_shift,
      work_schedule_day_station: day_station,
      starts_at: day_station.work_schedule_day.date.in_time_zone.change(hour: 22),
      ends_at: (day_station.work_schedule_day.date + 1.day).in_time_zone.change(hour: 2, min: 15))

    expect(shift).to be_valid
    expect(shift).to be_overnight
  end

  it "rejects times outside the quarter-hour raster" do
    shift = build(:work_shift)
    shift.starts_at = shift.starts_at.change(min: 7)

    expect(shift).not_to be_valid
    expect(shift.errors[:base]).to include("Start und Ende müssen auf 15 Minuten liegen")
  end

  it "rejects shifts lasting 24 hours" do
    shift = build(:work_shift)
    shift.ends_at = shift.starts_at + 24.hours

    expect(shift).not_to be_valid
  end

  it "rejects overlapping persisted shifts for the same user" do
    existing = create(:work_shift)
    other_station = existing.work_schedule_day.work_schedule_day_stations.second
    overlapping = build(:work_shift,
      work_schedule_day_station: other_station,
      user: existing.user,
      starts_at: existing.starts_at + 1.hour,
      ends_at: existing.ends_at + 1.hour)

    expect(overlapping).not_to be_valid
    expect(overlapping.errors[:user]).to include("hat in diesem Zeitraum bereits eine Schicht")
  end

  it "rejects overlapping users on the same catalog station across midnight" do
    schedule = create(:work_schedule, starts_on: Date.new(2026, 8, 7), ends_on: Date.new(2026, 8, 8))
    first_day, second_day = schedule.work_schedule_days.to_a
    first_station = first_day.work_schedule_day_stations.find_by!(name: "Bar")
    second_station = second_day.work_schedule_day_stations.find_by!(name: "Bar")
    create(:work_shift,
      work_schedule_day_station: first_station,
      starts_at: first_day.date.in_time_zone.change(hour: 22),
      ends_at: second_day.date.in_time_zone.change(hour: 2))
    overlap = build(:work_shift,
      work_schedule_day_station: second_station,
      starts_at: second_day.date.in_time_zone.change(hour: 1),
      ends_at: second_day.date.in_time_zone.change(hour: 4))

    expect(overlap).not_to be_valid
    expect(overlap.errors[:work_schedule_day_station]).to include("ist in diesem Zeitraum bereits besetzt")
  end

  it "allows adjacent shifts for the same person and station" do
    existing = create(:work_shift)
    adjacent = build(:work_shift,
      work_schedule_day_station: existing.work_schedule_day_station,
      user: existing.user,
      starts_at: existing.ends_at,
      ends_at: existing.ends_at + 2.hours)

    expect(adjacent).to be_valid
  end
end
