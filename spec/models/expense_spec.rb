require "rails_helper"

RSpec.describe Expense, type: :model do
  it "uses the central mileage factor and calculates reimbursement" do
    expense = build(:expense, km: 20, factor: nil)

    expense.factor = Expense::DEFAULT_FACTOR
    expect(expense.reimbursement_amount).to eq(BigDecimal("6.0"))
  end

  it "rejects future expenses" do
    expense = build(:expense, date: 1.day.from_now.to_date)

    expect(expense).not_to be_valid
    expect(expense.errors[:date]).to include("darf nicht in der Zukunft liegen")
  end
end
