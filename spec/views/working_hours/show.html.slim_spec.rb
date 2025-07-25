require 'rails_helper'

RSpec.describe "working_hours/show", type: :view do
  before(:each) do
    assign(:working_hour, WorkingHour.create!(
      break_minutes: 2,
      duration_minutes: 3,
      user: nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(//)
  end
end
