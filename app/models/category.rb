class Category < ApplicationRecord
  belongs_to :product_family, optional: true
  has_many :products, dependent: :nullify

  validates :title, presence: true
end
