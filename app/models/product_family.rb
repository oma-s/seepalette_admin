# == Schema Information
#
# Table name: product_families
#
#  id          :integer          not null, primary key
#  description :text
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProductFamily < ApplicationRecord
  has_many :categories, dependent: :nullify
  has_many :products, through: :categories, dependent: :nullify

  validates :title, presence: true
end
