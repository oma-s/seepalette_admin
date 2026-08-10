require 'rails_helper'

RSpec.describe "expenses/index", type: :view do
  before(:each) do
    user = create(:user)
    assign(:expenses, [
      Expense.create!(
        user: user,
        date: Date.new(2026, 8, 10),
        purpose: "Business trip",
        start_address: "Start Address",
        end_address: "End Address",
        km: 2,
        factor: "9.99"
      ),
      Expense.create!(
        user: user,
        date: Date.new(2026, 8, 11),
        purpose: "Business trip",
        start_address: "Start Address",
        end_address: "End Address",
        km: 2,
        factor: "9.99"
      )
    ])
  end

  it "renders a list of expenses" do
    render
    assert_select "#expenses > div", count: 2
    assert_select "#expenses > div p", text: /Start address:\s*Start Address/, count: 2
    assert_select "#expenses > div p", text: /End address:\s*End Address/, count: 2
    assert_select "#expenses > div p", text: /Km:\s*2/, count: 2
    assert_select "#expenses > div p", text: /Factor:\s*9.99/, count: 2
  end
end
