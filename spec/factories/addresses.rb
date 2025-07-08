FactoryBot.define do
  factory :address do
    address_line1 { "MyString" }
    address_line2 { "MyString" }
    zip { "MyString" }
    city { "MyString" }
    addressable { nil }
  end
end
