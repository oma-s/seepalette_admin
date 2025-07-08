class Expense < ApplicationRecord
  belongs_to :user

  validates :user, :date, :start_address, :end_address, :km, presence: true
  validates :km, numericality: { greater_than: 0 }
  validates :factor, numericality: { greater_than_or_equal_to: 0.1 }
end
