# == Schema Information
#
# Table name: categories
#
#  id                :integer          not null, primary key
#  description       :text
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_family_id :integer
#
# Indexes
#
#  index_categories_on_product_family_id  (product_family_id)
#

class Category < ApplicationRecord
  belongs_to :product_family, optional: true
  has_many :products, dependent: :nullify

  validates :title, presence: true
end
