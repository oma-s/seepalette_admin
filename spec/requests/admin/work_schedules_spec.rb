# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin work schedule planner", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, :admin) }
  let(:employee) { create(:user) }
  let(:schedule) { create(:work_schedule, starts_on: Date.new(2026, 8, 7), ends_on: Date.new(2026, 8, 8)) }
  let(:day) { schedule.work_schedule_days.first }
  let(:day_station) { day.work_schedule_day_stations.find_by!(name: "Bar") }

  before { sign_in admin }

  it "renders the planner shell and its JSON state" do
    get planner_admin_work_schedule_path(schedule)
    expect(response).to be_successful
    expect(response.body).to include("work-schedule-planner")

    get planner_data_admin_work_schedule_path(schedule), as: :json
    expect(response).to be_successful
    expect(response.parsed_body.dig("days", 0, "stations").pluck("name")).to include("Bar")
  end

  it "creates and edits an overnight shift through the shared endpoint" do
    expect {
      post save_shift_admin_work_schedule_path(schedule), params: {
        shift: {
          user_id: employee.id,
          day_station_id: day_station.id,
          date: day.date.iso8601,
          start_time: "22:00",
          end_time: "02:00",
          overnight: true,
          notes: "Abendschicht"
        }
      }, as: :json
    }.to change(WorkShift, :count).by(1)

    expect(response).to have_http_status(:ok)
    shift = WorkShift.last
    expect(shift).to be_overnight

    post save_shift_admin_work_schedule_path(schedule), params: {
      shift_id: shift.id,
      shift: {
        user_id: employee.id,
        day_station_id: day_station.id,
        date: day.date.iso8601,
        start_time: "21:45",
        end_time: "02:00",
        overnight: true
      }
    }, as: :json

    expect(response).to have_http_status(:ok)
    expect(shift.reload.starts_at.strftime("%H:%M")).to eq("21:45")
  end

  it "returns validation errors without partially saving a conflicting shift" do
    create(:work_shift, work_schedule_day_station: day_station, user: employee)

    expect {
      post save_shift_admin_work_schedule_path(schedule), params: {
        shift: {
          user_id: create(:user).id,
          day_station_id: day_station.id,
          date: day.date.iso8601,
          start_time: "11:00",
          end_time: "12:00",
          overnight: false
        }
      }, as: :json
    }.not_to change(WorkShift, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.parsed_body.fetch("errors").join).to include("bereits besetzt")
  end

  it "adds a day-only station and a notice" do
    post add_station_admin_work_schedule_path(schedule), params: {
      day_id: day.id,
      day_station: {name: "Technik", scope: "day", default_enabled: false}
    }, as: :json
    expect(response).to have_http_status(:ok)
    expect(day.work_schedule_day_stations.find_by(name: "Technik").station_id).to be_nil

    post save_notice_admin_work_schedule_path(schedule), params: {
      day_id: day.id,
      notice: {text: "Zapfanlagenprüfung", severity: "warning"}
    }, as: :json
    expect(response).to have_http_status(:ok)
    expect(day.day_notices.pluck(:text)).to include("Zapfanlagenprüfung")
    expect(day.day_notices.last.severity).to eq("warning")
  end

  it "publishes an immutable revision" do
    create(:work_shift, work_schedule_day_station: day_station, user: employee)

    post publish_schedule_admin_work_schedule_path(schedule), params: {}, as: :json

    expect(response).to have_http_status(:ok)
    expect(schedule.work_schedule_publications.count).to eq(1)
    expect(response.parsed_body["publication_state"]).to eq("published")
  end

  it "rejects authenticated users without the admin role" do
    sign_out admin
    sign_in employee

    get planner_data_admin_work_schedule_path(schedule), as: :json

    expect(response).to have_http_status(:forbidden)
  end
end
