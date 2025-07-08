FactoryBot.define do
  factory :expense do
    user { nil }
    date { "2025-07-08" }
    start_address { "MyString" }
    end_address { "MyString" }
    km { 1 }
    factor { "9.99" }
  end
end
