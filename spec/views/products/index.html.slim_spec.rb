require 'rails_helper'

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
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Stock Unit".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
