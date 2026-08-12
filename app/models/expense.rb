# == Schema Information
#
# Table name: expenses
#
#  id            :integer          not null, primary key
#  date          :date
#  end_address   :string           not null
#  factor        :decimal(3, 2)    default(0.3), not null
#  km            :integer          not null
#  purpose       :text             not null
#  start_address :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer          not null
#
# Indexes
#
#  index_expenses_on_user_id  (user_id)
#

class Expense < ApplicationRecord
  DEFAULT_FACTOR = BigDecimal("0.30")

  belongs_to :user

  attribute :factor, :decimal, default: -> { DEFAULT_FACTOR }

  validates :date, :start_address, :end_address, :purpose, :km, presence: true
  validates :km, numericality: {only_integer: true, greater_than: 0}
  validates :factor, numericality: {greater_than_or_equal_to: 0.1}
  validate :date_may_not_be_in_the_future

  scope :chronological, -> { order(date: :desc, created_at: :desc) }

  def reimbursement_amount
    return if km.blank? || factor.blank?

    km * factor
  end

  private

  def date_may_not_be_in_the_future
    return if date.blank? || date <= Time.zone.today

    errors.add(:date, "darf nicht in der Zukunft liegen")
  end
end
