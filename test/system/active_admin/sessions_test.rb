# frozen_string_literal: true

require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "visiting the root redirects to portal login" do
    visit root_path

    assert_current_path new_user_session_path
    assert_text(/Mitarbeiterportal/i)
    assert_text "Anmelden"
  end

  test "submitting the login form successfully" do
    default_admin_user

    visit new_user_session_path

    fill_in "E-Mail-Adresse", with: User::DEFAULT_EMAIL
    fill_in "Passwort", with: "password"
    click_on "Anmelden"

    assert_current_path root_path
    assert_text "Hallo Admin."
  end
end
