require 'rails_helper'

RSpec.describe "expenses/edit", type: :view do
  let(:expense) {
    Expense.create!(
      user: nil,
      start_address: "MyString",
      end_address: "MyString",
      km: 1,
      factor: "9.99"
    )
  }

  before(:each) do
    assign(:expense, expense)
  end

  it "renders the edit expense form" do
    render

    assert_select "form[action=?][method=?]", expense_path(expense), "post" do

      assert_select "input[name=?]", "expense[user_id]"

      assert_select "input[name=?]", "expense[start_address]"

      assert_select "input[name=?]", "expense[end_address]"

      assert_select "input[name=?]", "expense[km]"

      assert_select "input[name=?]", "expense[factor]"
    end
  end
end
