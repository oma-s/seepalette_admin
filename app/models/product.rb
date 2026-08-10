# == Schema Information
#
# Table name: products
#
#  id               :integer          not null, primary key
#  active           :boolean          default(FALSE)
#  ekp              :decimal(, )
#  menu_description :text
#  print_on_menu    :boolean
#  stock_target     :integer
#  stock_unit       :string
#  title            :string           not null
#  uvp              :decimal(, )
#  vkp              :decimal(, )
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :integer
#  supplier_id      :integer
#
# Indexes
#
#  index_products_on_category_id  (category_id)
#  index_products_on_supplier_id  (supplier_id)
#

#
# EKP: Einkaufspreis (Einkaufspreis)
# UVP: Unverbindliche Preisempfehlung (Unverbindliche Preisempfehlung)
# VKP: Verkaufspreis (Verkaufspreis)
# Stock Target: Zielbestand (Zielbestand)

class Product < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :supplier, optional: true

  validates :title, presence: true
  validates :ekp, :uvp, :vkp, :stock_target, numericality: {greater_than_or_equal_to: 0}, allow_nil: true
end
