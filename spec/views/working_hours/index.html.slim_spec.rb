require 'rails_helper'

RSpec.describe "working_hours/index", type: :view do
  before(:each) do
    assign(:working_hours, [
      WorkingHour.create!(
        break_minutes: 2,
        duration_minutes: 3,
        user: nil
      ),
      WorkingHour.create!(
        break_minutes: 2,
        duration_minutes: 3,
        user: nil
      )
    ])
  end

  it "renders a list of working_hours" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(3.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
