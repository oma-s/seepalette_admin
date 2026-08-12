require "rails_helper"

RSpec.describe WorkingHour, type: :model do
  it "calculates net duration" do
    working_hour = build(:working_hour, start_at: 2.days.ago.change(hour: 9), end_at: 2.days.ago.change(hour: 17), break_minutes: 30)

    expect(working_hour).to be_valid
    expect(working_hour.duration_minutes).to eq(450)
  end

  it "rejects future end times" do
    working_hour = build(:working_hour, start_at: 1.hour.from_now, end_at: 2.hours.from_now)

    expect(working_hour).not_to be_valid
    expect(working_hour.errors[:end_at]).to include("darf nicht in der Zukunft liegen")
  end

  it "rejects overlapping entries for the same user" do
    existing = create(:working_hour)
    overlap = build(:working_hour, user: existing.user, date: existing.date, start_at: existing.start_at + 1.hour, end_at: existing.end_at + 1.hour)

    expect(overlap).not_to be_valid
    expect(overlap.errors[:base]).to include(/überschneidet/)
  end

  it "handles incomplete form values without raising" do
    working_hour = build(:working_hour, start_at: nil, end_at: nil)

    expect { working_hour.valid? }.not_to raise_error
    expect(working_hour).not_to be_valid
  end
end
