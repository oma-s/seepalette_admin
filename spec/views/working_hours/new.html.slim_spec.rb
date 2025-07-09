require 'rails_helper'

RSpec.describe "working_hours/new", type: :view do
  before(:each) do
    assign(:working_hour, WorkingHour.new(
      break_minutes: 1,
      duration_minutes: 1,
      user: nil
    ))
  end

  it "renders new working_hour form" do
    render

    assert_select "form[action=?][method=?]", working_hours_path, "post" do

      assert_select "input[name=?]", "working_hour[break_minutes]"

      assert_select "input[name=?]", "working_hour[duration_minutes]"

      assert_select "input[name=?]", "working_hour[user_id]"
    end
  end
end
