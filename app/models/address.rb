class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :address_line1, :zip, :city, :addressable, presence: true

  def to_s
    "#{address_line1}, #{city}, #{zip}"
  end
end
