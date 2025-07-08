require 'rails_helper'

RSpec.describe "expenses/new", type: :view do
  before(:each) do
    assign(:expense, Expense.new(
      user: nil,
      start_address: "MyString",
      end_address: "MyString",
      km: 1,
      factor: "9.99"
    ))
  end

  it "renders new expense form" do
    render

    assert_select "form[action=?][method=?]", expenses_path, "post" do

      assert_select "input[name=?]", "expense[user_id]"

      assert_select "input[name=?]", "expense[start_address]"

      assert_select "input[name=?]", "expense[end_address]"

      assert_select "input[name=?]", "expense[km]"

      assert_select "input[name=?]", "expense[factor]"
    end
  end
end
