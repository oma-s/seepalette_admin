# frozen_string_literal: true

require "application_system_test_case"

class WorkSchedulesTest < ApplicationSystemTestCase
  setup do
    @employee = User.create!(
      given_name: "Lea",
      family_name: "Beispiel",
      email: "lea@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @second_employee = User.create!(
      given_name: "Tom",
      family_name: "Beispiel",
      email: "tom@example.com",
      password: "password",
      password_confirmation: "password"
    )
    @schedule = WorkSchedule.create!(
      title: "Schichtplan 7.–9.8.",
      starts_on: Date.new(2026, 8, 7),
      ends_on: Date.new(2026, 8, 9)
    )
    @day = @schedule.work_schedule_days.first
    @bar = @day.work_schedule_day_stations.find_by!(name: "Bar")
    @bar.work_shifts.create!(
      user: @employee,
      starts_at: Time.zone.local(2026, 8, 7, 10),
      ends_at: Time.zone.local(2026, 8, 7, 18)
    )

    sign_in default_admin_user, scope: :user
  end

  test "switching between grid and list and editing a shift" do
    visit planner_admin_work_schedule_path(@schedule)

    assert_text "Schichtplan 7.–9.8."
    assert_selector ".planner-grid"
    assert_text "Lea Beispiel"

    click_on "Liste"
    assert_selector ".planner-shift-card"
    assert_selector ".planner-shift-station", text: "Bar"
    assert_text "10:00–18:00"

    find(".planner-shift-card", text: "Lea Beispiel").click
    assert_selector "#shift-dialog[open]"
    assert_selector "select[name='start_hour'] option:checked", text: "10"
    assert_selector "select[name='start_minute'] option:checked", text: "00"
    assert_select "Mitarbeiter/in", selected: "Lea Beispiel"
    click_on "Abbrechen"
  end

  test "creating a shift with the shared form" do
    visit planner_admin_work_schedule_path(@schedule)
    click_on "Schicht hinzufügen"

    within "#shift-dialog" do
      select "Tom Beispiel", from: "Mitarbeiter/in"
      select "Runner", from: "Station"
      find("select[name='start_hour']").select("18")
      find("select[name='start_minute']").select("00")
      find("select[name='end_hour']").select("22")
      find("select[name='end_minute']").select("00")
      click_on "Speichern"
    end

    assert_text "Schicht gespeichert"
    click_on "Liste"
    assert_text "Tom Beispiel"
    assert_text "18:00–22:00"
  end

  test "adding a notice and publishing a revision" do
    visit planner_admin_work_schedule_path(@schedule)
    click_on "+ Hinweis hinzufügen"

    within "#notice-dialog" do
      select "Warnung", from: "Art"
      fill_in "Hinweis", with: "Techniker kommt vorbei"
      click_on "Speichern"
    end
    assert_text "Techniker kommt vorbei"
    assert_selector ".planner-callout--warning"

    click_on "Veröffentlichen"
    assert_text "Dienstplan veröffentlicht"
    assert_text "Revision 1"
  end

  test "using the list as the default view on a small screen" do
    page.current_window.resize_to(390, 844)
    visit planner_admin_work_schedule_path(@schedule)
    page.execute_script("localStorage.removeItem('seepalette-planner-view')")
    page.refresh

    assert_selector ".planner-list"
    assert_selector ".planner-view-toggle .is-active", text: "Liste"
    assert_text "Lea Beispiel"
  ensure
    page.current_window.resize_to(1400, 1400)
  end
end
