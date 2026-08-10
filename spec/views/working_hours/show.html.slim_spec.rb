require 'rails_helper'

RSpec.describe "working_hours/show", type: :view do
  before(:each) do
    assign(:working_hour, WorkingHour.create!(
      start_at: Time.zone.parse("2026-08-10 09:00"),
      end_at: Time.zone.parse("2026-08-10 17:00"),
      break_minutes: 2,
      user: create(:user)
    ))
  end

  it "renders attributes in <p>" do
    render
    assert_select "p", text: /Break minutes:\s*2/
    assert_select "p", text: /Duration minutes:\s*478/
  end
end
