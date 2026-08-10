# == Schema Information
#
# Table name: expenses
#
#  id            :integer          not null, primary key
#  date          :date
#  end_address   :string           not null
#  factor        :decimal(3, 2)    not null
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
# Foreign Keys
#
#  user_id  (user_id => users.id)
#

class Expense < ApplicationRecord
  belongs_to :user

  validates :user, :date, :start_address, :end_address, :km, presence: true
  validates :km, numericality: { greater_than: 0 }
  validates :factor, numericality: { greater_than_or_equal_to: 0.1 }
end
