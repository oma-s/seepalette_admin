# == Schema Information
#
# Table name: suppliers
#
#  id                      :integer          not null, primary key
#  contact_email           :string
#  contact_phone           :string
#  description             :string
#  personal_contact_name   :string
#  preffered_time_to_order :string
#  title                   :string           not null
#  website                 :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Supplier < ApplicationRecord
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :products, dependent: :nullify

  validates :title, presence: true
  validates :contact_email, format: {with: URI::MailTo::EMAIL_REGEXP}, allow_blank: true
end
