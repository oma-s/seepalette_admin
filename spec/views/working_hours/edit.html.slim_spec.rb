require 'rails_helper'

RSpec.describe "working_hours/edit", type: :view do
  let(:working_hour) {
    WorkingHour.create!(
      start_at: Time.zone.parse("2026-08-10 09:00"),
      end_at: Time.zone.parse("2026-08-10 17:00"),
      break_minutes: 1,
      user: create(:user)
    )
  }

  before(:each) do
    assign(:working_hour, working_hour)
  end

  it "renders the edit working_hour form" do
    render

    assert_select "form[action=?][method=?]", working_hour_path(working_hour), "post" do

      assert_select "input[name=?]", "working_hour[break_minutes]"

      assert_select "input[name=?]", "working_hour[duration_minutes]"

      assert_select "input[name=?]", "working_hour[user_id]"
    end
  end
end
