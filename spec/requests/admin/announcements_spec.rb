# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin announcements", type: :request do
  include Devise::Test::IntegrationHelpers

  it "allows admins to manage portal announcements" do
    sign_in create(:user, :admin)

    expect {
      post admin_announcements_path, params: {
        announcement: {title: "Neue Öffnungszeiten", body: "Ab Montag gilt der neue Plan.", severity: "warning", active: true, priority: 5}
      }
    }.to change(Announcement, :count).by(1)

    expect(response).to redirect_to(admin_announcement_path(Announcement.last))
  end

  it "does not allow employees into the admin area" do
    sign_in create(:user)

    get admin_announcements_path

    expect(response).to redirect_to(root_path)
  end
end
