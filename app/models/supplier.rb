class Supplier < ApplicationRecord
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :products, dependent: :nullify

  validates :title, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
