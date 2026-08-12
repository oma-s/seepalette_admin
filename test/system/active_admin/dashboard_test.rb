# frozen_string_literal: true

require "application_system_test_case"

class AdminUsersTest < ApplicationSystemTestCase
  test "visiting root renders the employee portal" do
    sign_in default_admin_user, scope: :user
    visit root_path
    assert_current_path root_path
    assert_text(/Mitarbeiterportal/i)
    assert_text "Hallo Admin."
  end

  test "visiting the admin root renders dashboard" do
    sign_in default_admin_user, scope: :user
    visit admin_root_path
    assert_text "Welcome to ActiveAdmin"
  end

  test "visiting the admin dashboard" do
    sign_in default_admin_user, scope: :user
    visit admin_dashboard_path
    assert_text "Welcome to ActiveAdmin"
  end
end
