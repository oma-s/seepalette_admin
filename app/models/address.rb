# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  address_line1    :string           not null
#  address_line2    :string
#  addressable_type :string
#  city             :string           not null
#  zip              :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :integer
#
# Indexes
#
#  index_addresses_on_addressable  (addressable_type,addressable_id)
#

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :address_line1, :zip, :city, presence: true

  def to_s
    "#{address_line1}, #{city}, #{zip}"
  end
end
