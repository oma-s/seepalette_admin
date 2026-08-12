# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkSchedule, type: :model do
  it "creates every calendar day and the default stations" do
    schedule = create(:work_schedule)

    expect(schedule.work_schedule_days.pluck(:date)).to eq((schedule.starts_on..schedule.ends_on).to_a)
    expect(schedule.work_schedule_days.first.work_schedule_day_stations.pluck(:name)).to include("Bar", "Küche", "CvD")
  end

  it "rejects an end date before the start date" do
    schedule = build(:work_schedule, starts_on: Date.new(2026, 8, 9), ends_on: Date.new(2026, 8, 7))

    expect(schedule).not_to be_valid
    expect(schedule.errors[:ends_on]).to include("muss am oder nach dem Startdatum liegen")
  end

  it "extends its generated calendar days" do
    schedule = create(:work_schedule, starts_on: Date.new(2026, 8, 7), ends_on: Date.new(2026, 8, 8))

    schedule.update!(ends_on: Date.new(2026, 8, 10))

    expect(schedule.work_schedule_days.reload.pluck(:date)).to eq((Date.new(2026, 8, 7)..Date.new(2026, 8, 10)).to_a)
  end

  it "does not shrink over a day containing shifts" do
    schedule = create(:work_schedule)
    removed_day = schedule.work_schedule_days.last
    create(:work_shift, work_schedule_day_station: removed_day.work_schedule_day_stations.first)

    expect(schedule.update(ends_on: removed_day.date - 1.day)).to be(false)
    expect(schedule.errors[:base]).to include(/nicht verkürzt/)
  end

  it "keeps an immutable publication until the changed schedule is republished" do
    admin = create(:user, :admin)
    schedule = create(:work_schedule)
    employee = create(:user, schedule_color: "rose")
    create(:work_shift, work_schedule_day_station: schedule.work_schedule_days.first.work_schedule_day_stations.first, user: employee)

    first = schedule.publish!(admin)
    expect(schedule.reload.publication_state).to eq(:published)
    expect(first.payload.deep_symbolize_keys.dig(:days, 0, :stations, 0, :shifts, 0, :user_color)).to eq("rose")

    schedule.work_schedule_days.first.day_notices.create!(text: "Neue Information")
    expect(schedule.reload.publication_state).to eq(:changes_pending)
    expect(first.reload.payload.deep_symbolize_keys.dig(:days, 0, :notices)).to be_empty

    second = schedule.publish!(admin)
    expect(second.revision).to eq(2)
    expect(schedule.reload.publication_state).to eq(:published)
  end

  it "requires a shift before publishing" do
    schedule = create(:work_schedule)

    expect { schedule.publish!(create(:user, :admin)) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "does not publish a period overlapping another published schedule" do
    admin = create(:user, :admin)
    first = create(:work_schedule, starts_on: Date.new(2026, 8, 7), ends_on: Date.new(2026, 8, 9))
    create(:work_shift, work_schedule_day_station: first.work_schedule_days.first.work_schedule_day_stations.first)
    first.publish!(admin)

    overlapping = create(:work_schedule, starts_on: Date.new(2026, 8, 9), ends_on: Date.new(2026, 8, 11))
    create(:work_shift, work_schedule_day_station: overlapping.work_schedule_days.last.work_schedule_day_stations.first)

    expect { overlapping.publish!(admin) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(overlapping.errors[:base].join).to include("überschneidet")
  end
end
