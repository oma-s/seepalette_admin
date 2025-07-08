FactoryBot.define do
  factory :product do
    title { "MyString" }
    menu_description { "MyText" }
    ekp { "9.99" }
    uvp { "9.99" }
    vkp { "9.99" }
    stock_unit { "MyString" }
    stock_target { 1 }
    print_on_menu { false }
    active { false }
    category { nil }
  end
end
