#
# EKP: Einkaufspreis (Einkaufspreis)
# UVP: Unverbindliche Preisempfehlung (Unverbindliche Preisempfehlung)
# VKP: Verkaufspreis (Verkaufspreis)
# Stock Target: Zielbestand (Zielbestand)

class Product < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :supplier, optional: true

  validates :title, presence: true
  validates :ekp, :uvp, :vkp, :stock_target, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
