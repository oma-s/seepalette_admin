require "rails_helper"

RSpec.describe "products/index", type: :view do
  before(:each) do
    assign(:products, [
      Product.create!(
        title: "Title",
        menu_description: "MyText",
        ekp: "9.99",
        uvp: "9.99",
        vkp: "9.99",
        stock_unit: "Stock Unit",
        stock_target: 2,
        print_on_menu: false,
        active: false,
        category: nil
      ),
      Product.create!(
        title: "Title",
        menu_description: "MyText",
        ekp: "9.99",
        uvp: "9.99",
        vkp: "9.99",
        stock_unit: "Stock Unit",
        stock_target: 2,
        print_on_menu: false,
        active: false,
        category: nil
      )
    ])
  end

  it "renders a list of products" do
    render
    assert_select "#products > div", count: 2
    assert_select "#products > div p", text: /Title:\s*Title/, count: 2
    assert_select "#products > div p", text: /Menu description:\s*MyText/, count: 2
    assert_select "#products > div p", text: /Ekp:\s*9.99/, count: 2
    assert_select "#products > div p", text: /Uvp:\s*9.99/, count: 2
    assert_select "#products > div p", text: /Vkp:\s*9.99/, count: 2
    assert_select "#products > div p", text: /Stock unit:\s*Stock Unit/, count: 2
    assert_select "#products > div p", text: /Stock target:\s*2/, count: 2
    assert_select "#products > div p", text: /Print on menu:\s*false/, count: 2
    assert_select "#products > div p", text: /Active:\s*false/, count: 2
  end
end
