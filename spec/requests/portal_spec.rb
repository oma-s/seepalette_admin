# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Mitarbeiterportal", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, given_name: "Mara") }

  it "requires a login and sends every role to the welcome page" do
    get portal_root_path
    expect(response).to redirect_to(new_user_session_path)

    admin = create(:user, :admin)
    post user_session_path, params: {user: {email: admin.email, password: "password"}}
    expect(response).to redirect_to(portal_root_path)
  end

  it "renders visible announcements and the next published shift" do
    announcement = create(:announcement, title: "Teamabend")
    create(:announcement, title: "Versteckt", active: false)
    schedule = published_schedule_for(user)

    sign_in user
    get portal_root_path

    expect(response).to be_successful
    expect(response.body).to include(announcement.title, "Teamabend", "Nächste Schichten", schedule.title)
    expect(response.body).not_to include("Versteckt")
  end

  it "shows only the published snapshot and exposes no colleague detail link" do
    colleague = create(:user, given_name: "Kai")
    schedule = create(:work_schedule, starts_on: Time.zone.today, ends_on: 2.days.from_now.to_date, notes: "Planhinweis")
    day = schedule.work_schedule_days.second
    day.day_notices.create!(text: "Lieferung kommt", severity: "warning")
    own_shift = create(:work_shift,
      user: user,
      work_schedule_day_station: day.work_schedule_day_stations.find_by!(name: "Bar"),
      starts_at: day.date.in_time_zone.change(hour: 10),
      ends_at: day.date.in_time_zone.change(hour: 16),
      notes: "Veröffentlichte Notiz")
    create(:work_shift,
      user: colleague,
      work_schedule_day_station: day.work_schedule_day_stations.find_by!(name: "Küche"),
      starts_at: day.date.in_time_zone.change(hour: 11),
      ends_at: day.date.in_time_zone.change(hour: 17),
      notes: "Kollegennotiz")
    schedule.publish!(create(:user, :admin))
    own_shift.update!(notes: "Unveröffentlichter Entwurf")

    sign_in user
    get portal_work_schedule_path(schedule_id: schedule.id)
    expect(response.body).to include("Veröffentlichte Notiz", "Lieferung kommt")
    expect(response.body).not_to include("Unveröffentlichter Entwurf", "Kollegennotiz")

    get portal_work_schedule_path(schedule_id: schedule.id, view: "team")
    expect(response.body).to include("Kollegennotiz", colleague.to_s)
    expect(response.body).not_to match(%r{href="[^"]*/users/#{colleague.id}})
  end

  it "creates, updates and deletes only the current user's working hours" do
    other_entry = create(:working_hour)
    sign_in user

    expect {
      post portal_working_hours_path, params: {
        working_hour: {
          date: 2.days.ago.to_date.iso8601,
          start_time: "09:00",
          end_time: "17:00",
          overnight: "0",
          break_minutes: 30,
          user_id: other_entry.user_id,
          duration_minutes: 1
        }
      }
    }.to change { user.working_hours.count }.by(1)

    entry = user.working_hours.last
    expect(entry.duration_minutes).to eq(450)
    expect(entry.user).to eq(user)

    patch portal_working_hour_path(entry), params: {
      working_hour: {date: entry.date.iso8601, start_time: "10:00", end_time: "17:00", break_minutes: 30}
    }
    expect(response).to redirect_to(portal_working_hours_path(month: entry.date.strftime("%Y-%m")))
    expect(entry.reload.start_at.strftime("%H:%M")).to eq("10:00")

    get edit_portal_working_hour_path(other_entry)
    expect(response).to have_http_status(:not_found)

    expect { delete portal_working_hour_path(entry) }.to change(WorkingHour, :count).by(-1)
  end

  it "creates mileage expenses with the central factor and protects other users' entries" do
    other_expense = create(:expense)
    sign_in user

    expect {
      post portal_expenses_path, params: {
        expense: {
          date: 1.day.ago.to_date.iso8601,
          start_address: "Am See 1",
          end_address: "Markt 2",
          purpose: "Besorgung",
          km: 20,
          factor: 9.99,
          user_id: other_expense.user_id
        }
      }
    }.to change { user.expenses.count }.by(1)

    expense = user.expenses.last
    expect(expense.factor).to eq(Expense::DEFAULT_FACTOR)
    expect(expense.reimbursement_amount).to eq(BigDecimal("6.0"))

    get edit_portal_expense_path(other_expense)
    expect(response).to have_http_status(:not_found)

    expect { delete portal_expense_path(expense) }.to change(Expense, :count).by(-1)
  end

  it "rejects working hours and expenses in the future" do
    sign_in user

    post portal_working_hours_path, params: {
      working_hour: {date: 1.day.from_now.to_date.iso8601, start_time: "09:00", end_time: "17:00", break_minutes: 30}
    }
    expect(response).to have_http_status(:unprocessable_content)

    post portal_expenses_path, params: {
      expense: {date: 1.day.from_now.to_date.iso8601, start_address: "A", end_address: "B", purpose: "Test", km: 10}
    }
    expect(response).to have_http_status(:unprocessable_content)
  end

  private

  def published_schedule_for(employee)
    schedule = create(:work_schedule, starts_on: Time.zone.today, ends_on: 2.days.from_now.to_date)
    day_station = schedule.work_schedule_days.second.work_schedule_day_stations.first
    create(:work_shift,
      user: employee,
      work_schedule_day_station: day_station,
      starts_at: day_station.work_schedule_day.date.in_time_zone.change(hour: 10),
      ends_at: day_station.work_schedule_day.date.in_time_zone.change(hour: 18))
    schedule.publish!(create(:user, :admin))
    schedule
  end
end
