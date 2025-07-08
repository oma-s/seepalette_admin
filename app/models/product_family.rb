class ProductFamily < ApplicationRecord
  has_many :categories, dependent: :nullify
  has_many :products, through: :categories, dependent: :nullify

  validates :title, presence: true
end
