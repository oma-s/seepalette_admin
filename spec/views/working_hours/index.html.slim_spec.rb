require 'rails_helper'

RSpec.describe "working_hours/index", type: :view do
  before(:each) do
    user = create(:user)
    assign(:working_hours, [
      WorkingHour.create!(
        start_at: Time.zone.parse("2026-08-10 09:00"),
        end_at: Time.zone.parse("2026-08-10 17:00"),
        break_minutes: 2,
        user: user
      ),
      WorkingHour.create!(
        start_at: Time.zone.parse("2026-08-11 09:00"),
        end_at: Time.zone.parse("2026-08-11 17:00"),
        break_minutes: 2,
        user: user
      )
    ])
  end

  it "renders a list of working_hours" do
    render
    assert_select "#working_hours > div", count: 2
    assert_select "#working_hours > div p", text: /Break minutes:\s*2/, count: 2
    assert_select "#working_hours > div p", text: /Duration minutes:\s*478/, count: 2
  end
end
