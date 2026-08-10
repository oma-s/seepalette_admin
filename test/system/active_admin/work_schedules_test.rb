# frozen_string_literal: true

require "application_system_test_case"

class WorkSchedulesTest < ApplicationSystemTestCase
  setup do
    @employee = User.create!(
      given_name: "Lea",
      family_name: "Example",
      email: "lea@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @schedule = WorkSchedule.create!(
      title: "Schichtplan 7.-9.8.",
      starts_on: Date.new(2026, 8, 7),
      ends_on: Date.new(2026, 8, 9),
      work_schedule_days_attributes: [{
        date: Date.new(2026, 8, 8),
        title: "Open-Air-Kino und Puppentheater",
        work_shifts_attributes: [{
          user: @employee,
          position: "Bar",
          starts_at: Time.zone.local(2026, 8, 8, 10),
          ends_at: Time.zone.local(2026, 8, 8, 18),
          break_minutes: 30
        }]
      }]
    )
  end

  test "visiting the schedule index and show page" do
    sign_in default_admin_user, scope: :user

    visit admin_work_schedules_path
    assert_text "Schichtplan 7.-9.8."
    assert_text "Draft"

    visit admin_work_schedule_path(@schedule)
    assert_text "Open-Air-Kino und Puppentheater"
    assert_text "Lea Example"
    assert_text "Bar"
    assert_text "7h 30min"
  end

  test "rendering the nested schedule form" do
    sign_in default_admin_user, scope: :user

    visit edit_admin_work_schedule_path(@schedule)

    assert_field "Title", with: "Schichtplan 7.-9.8."
    assert_field "Position", with: "Bar"
    assert_link "Add schedule day"
    assert_link "Add shift"
  end

  test "adding a day and shift to a new schedule form" do
    sign_in default_admin_user, scope: :user

    visit new_admin_work_schedule_path
    click_on "Add schedule day"

    assert_selector "input[name*='work_schedule_days_attributes'][name$='[title]']"

    click_on "Add shift"

    assert_selector "input[name*='work_shifts_attributes'][name$='[position]']"
    assert_selector "select[name*='work_shifts_attributes'][name$='[user_id]']"
  end

  test "showing planned shifts on the user page" do
    sign_in default_admin_user, scope: :user

    visit admin_user_path(@employee)

    assert_text "Planned Shifts"
    assert_text "Schichtplan 7.-9.8."
    assert_text "Open-Air-Kino und Puppentheater"
    assert_text "Bar"
  end
end
