# frozen_string_literal: true

require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "visiting the index" do
    sign_in default_admin_user, scope: :user

    visit admin_users_path

    assert_text "Users"
    assert_selector "table tbody tr", count: 1
    assert_text "admin@example.com"
  end

  test "visiting the show" do
    admin = default_admin_user
    schedule = WorkSchedule.create!(title: "Testplan", starts_on: Date.new(2026, 8, 10), ends_on: Date.new(2026, 8, 10))
    day_station = schedule.work_schedule_days.first.work_schedule_day_stations.first
    day_station.work_shifts.create!(
      user: admin,
      starts_at: Time.zone.local(2026, 8, 10, 10),
      ends_at: Time.zone.local(2026, 8, 10, 12)
    )
    sign_in admin, scope: :user

    visit admin_user_path(admin)

    assert_text "admin@example.com"
    assert_text "Testplan"
    assert_text day_station.name
    assert_link "User bearbeiten", href: edit_admin_user_path(admin)
    assert_link "User löschen", href: admin_user_path(admin)
  end

  test "visiting the new and submitting" do
    sign_in default_admin_user, scope: :user

    visit new_admin_user_path

    assert_selector "input[name='user[schedule_color]']", count: User::SCHEDULE_COLORS.size
    assert_selector "input[name='user[schedule_color]']:checked", count: 1

    page.execute_script(<<~JAVASCRIPT)
      const form = document.querySelector('form[action="/admin/users"]');
      form.elements['user[given_name]'].value = 'Test';
      form.elements['user[family_name]'].value = 'User';
      form.elements['user[email]'].value = 'test@example.com';
      form.elements['user[password]'].value = 'password';
      form.elements['user[password_confirmation]'].value = 'password';
      form.submit();
    JAVASCRIPT

    assert_current_path admin_user_path(User.last)
    assert_text "test@example.com"
  end

  test "visiting the edit" do
    sign_in default_admin_user, scope: :user

    visit edit_admin_user_path(default_admin_user)

    assert_text "admin@example.com"
  end

  test "updating an admin user is successful" do
    admin_user = User.create!(given_name: "Test", family_name: "User", email: "test@example.com", password: "password",
      password_confirmation: "password")
    sign_in default_admin_user, scope: :user

    visit edit_admin_user_path(admin_user)
    fill_in "Email", with: "updated@example.com"
    fill_in "Password", with: "password", id: "user_password"
    fill_in "Password confirmation", with: "password"
    find("form input[type='submit']").click

    assert_current_path admin_user_path(admin_user)
    assert_text "updated@example.com"
    refute_text "test@example.com"
  end

  test "updating the default admin user is blocked" do
    sign_in default_admin_user, scope: :user

    visit edit_admin_user_path(default_admin_user)
    fill_in "Email", with: "test@example.com"
    find("form input[type='submit']").click

    default_admin_user.reload
    assert_current_path edit_admin_user_path(default_admin_user)
    assert_text "The default admin user cannot be modified."
    refute_equal default_admin_user.email, "test@example.com"
  end

  test "deleting an admin user is successful" do
    admin_user = User.create!(given_name: "Test", family_name: "User", email: "test@example.com", password: "password",
      password_confirmation: "password")
    sign_in default_admin_user, scope: :user

    visit admin_user_path(admin_user)
    submit_delete_user(admin_user_path(admin_user))

    assert_current_path admin_users_path
    assert_not User.exists?(admin_user.id)
    refute_text "test@example.com"
  end

  test "deleting the default admin user is blocked" do
    sign_in default_admin_user, scope: :user

    visit admin_user_path(default_admin_user)
    submit_delete_user(admin_user_path(default_admin_user))

    default_admin_user.reload
    assert_current_path admin_user_path(default_admin_user)
    assert_text "The default admin user cannot be modified."
  end

  private

  def submit_delete_user(path)
    page.execute_script(<<~JAVASCRIPT)
      const form = document.createElement('form');
      form.method = 'post';
      form.action = #{path.to_json};

      const method = document.createElement('input');
      method.type = 'hidden';
      method.name = '_method';
      method.value = 'delete';
      form.appendChild(method);

      document.body.appendChild(form);
      form.submit();
    JAVASCRIPT
  end
end
