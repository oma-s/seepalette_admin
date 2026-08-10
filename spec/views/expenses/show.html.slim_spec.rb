require "rails_helper"

RSpec.describe "expenses/show", type: :view do
  before(:each) do
    assign(:expense, Expense.create!(
      user: create(:user),
      date: Date.new(2026, 8, 10),
      purpose: "Business trip",
      start_address: "Start Address",
      end_address: "End Address",
      km: 2,
      factor: "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    assert_select "p", text: /Date:\s*2026-08-10/
    expect(rendered).to match(/Start Address/)
    expect(rendered).to match(/End Address/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/9.99/)
  end
end
