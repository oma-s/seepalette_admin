# frozen_string_literal: true

require "rails_helper"

RSpec.describe DayNotice, type: :model do
  it "orders critical notices before warnings and information, then chronologically" do
    day = create(:work_schedule).work_schedule_days.first
    info = create(:day_notice, work_schedule_day: day, severity: "info", created_at: 3.minutes.ago)
    newest_critical = create(:day_notice, work_schedule_day: day, severity: "critical", created_at: 1.minute.ago)
    warning = create(:day_notice, work_schedule_day: day, severity: "warning", created_at: 4.minutes.ago)
    oldest_critical = create(:day_notice, work_schedule_day: day, severity: "critical", created_at: 2.minutes.ago)

    expect(day.day_notices.reload).to eq([oldest_critical, newest_critical, warning, info])
  end

  it "rejects unsupported severities" do
    notice = build(:day_notice, severity: "urgent")

    expect(notice).not_to be_valid
  end
end
