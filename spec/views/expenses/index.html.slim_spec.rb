require 'rails_helper'

RSpec.describe "expenses/index", type: :view do
  before(:each) do
    assign(:expenses, [
      Expense.create!(
        user: nil,
        start_address: "Start Address",
        end_address: "End Address",
        km: 2,
        factor: "9.99"
      ),
      Expense.create!(
        user: nil,
        start_address: "Start Address",
        end_address: "End Address",
        km: 2,
        factor: "9.99"
      )
    ])
  end

  it "renders a list of expenses" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Start Address".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("End Address".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
  end
end
