# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "filters people available for new shifts" do
    available = create(:user, schedulable: true)
    create(:user, schedulable: false)

    expect(User.schedulable).to contain_exactly(available)
  end

  it "assigns a valid schedule color to new people" do
    user = User.new

    expect(User::SCHEDULE_COLORS).to have_key(user.schedule_color)
  end

  it "rejects arbitrary schedule colors" do
    user = build(:user, schedule_color: "neon-transparent")

    expect(user).not_to be_valid
  end

  it "can grant and remove the admin role through the admin form attribute" do
    user = create(:user)
    existing_admin = create(:user, :admin)

    user.update!(admin_role: true)
    expect(user).to be_admin

    user.update!(admin_role: false)
    expect(user).not_to be_admin
    expect(existing_admin).to be_admin
  end

  it "does not remove the role from the protected default admin" do
    admin = create(:user, :admin, email: User::DEFAULT_EMAIL)

    expect(admin.update(admin_role: false)).to be(false)
    expect(admin.errors[:admin_role]).to include(/geschützten Standard-Admin/)
  end
end
