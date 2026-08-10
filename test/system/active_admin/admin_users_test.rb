# frozen_string_literal: true

require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "visiting the index" do
    sign_in default_admin_user, scope: :user

    visit admin_users_path

    assert_text "Users"
    assert_text "Showing 1 of 1"
    assert_text "admin@example.com"
  end

  test "visiting the show" do
    sign_in default_admin_user, scope: :user

    visit admin_user_path(default_admin_user)

    assert_text "admin@example.com"
    assert_selector "a", text: "Edit User"
    assert_selector "a", text: "Delete User"
  end

  test "visiting the new and submitting" do
    sign_in default_admin_user, scope: :user

    visit new_admin_user_path

    page.execute_script(<<~JAVASCRIPT)
      const form = document.querySelector('form[action="/admin/users"]');
      form.elements['user[given_name]'].value = 'Test';
      form.elements['user[family_name]'].value = 'User';
      form.elements['user[email]'].value = 'test@example.com';
      form.elements['user[password]'].value = 'password';
      form.elements['user[password_confirmation]'].value = 'password';
      form.submit();
    JAVASCRIPT

    assert_text "User was successfully created.", wait: 5
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
    click_on "Update User"

    assert_current_path admin_user_path(admin_user)
    assert_text "User was successfully updated."
    assert_text "updated@example.com"
    refute_text "test@example.com"
  end

  test "updating the default admin user is blocked" do
    sign_in default_admin_user, scope: :user

    visit edit_admin_user_path(default_admin_user)
    fill_in "Email", with: "test@example.com"
    click_on "Update User"

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
    accept_confirm do
      click_on "Delete User"
    end

    assert_current_path admin_users_path
    assert_text "User was successfully destroyed."
    refute_text "test@example.com"
  end

  test "deleting the default admin user is blocked" do
    sign_in default_admin_user, scope: :user

    visit admin_user_path(default_admin_user)
    accept_confirm do
      click_on "Delete User"
    end

    default_admin_user.reload
    assert_current_path admin_user_path(default_admin_user)
    assert_text "The default admin user cannot be modified."
  end
end
