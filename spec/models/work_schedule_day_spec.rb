# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkScheduleDay, type: :model do
  it "accepts a configurable quarter-hour grid ending on the following day" do
    day = create(:work_schedule).work_schedule_days.first

    expect(day.update(grid_start_minute: 8 * 60 + 15, grid_end_minute: 26 * 60)).to be(true)
  end

  it "rejects grid boundaries outside the quarter-hour raster" do
    day = create(:work_schedule).work_schedule_days.first

    expect(day.update(grid_start_minute: 421)).to be(false)
    expect(day.errors[:base]).to include("Zeiten müssen auf 15 Minuten liegen")
  end

  it "copies selected day content atomically" do
    schedule = create(:work_schedule, starts_on: Date.new(2026, 8, 7), ends_on: Date.new(2026, 8, 8))
    source, target = schedule.work_schedule_days.to_a
    source.day_notices.create!(text: "Zapfanlagenprüfung", severity: "critical")
    shift = create(:work_shift, work_schedule_day_station: source.work_schedule_day_stations.first)

    target.copy_from!(source, include_stations: true, include_notices: true, include_shifts: true)

    copied = target.work_shifts.first
    expect(target.day_notices.pluck(:text)).to include("Zapfanlagenprüfung")
    expect(target.day_notices.first.severity).to eq("critical")
    expect(copied.user).to eq(shift.user)
    expect(copied.starts_at.to_date).to eq(target.date)
  end
end
