require 'rails_helper'

RSpec.describe "products/new", type: :view do
  before(:each) do
    assign(:product, Product.new(
      title: "MyString",
      menu_description: "MyText",
      ekp: "9.99",
      uvp: "9.99",
      vkp: "9.99",
      stock_unit: "MyString",
      stock_target: 1,
      print_on_menu: false,
      active: false,
      category: nil
    ))
  end

  it "renders new product form" do
    render

    assert_select "form[action=?][method=?]", products_path, "post" do

      assert_select "input[name=?]", "product[title]"

      assert_select "textarea[name=?]", "product[menu_description]"

      assert_select "input[name=?]", "product[ekp]"

      assert_select "input[name=?]", "product[uvp]"

      assert_select "input[name=?]", "product[vkp]"

      assert_select "input[name=?]", "product[stock_unit]"

      assert_select "input[name=?]", "product[stock_target]"

      assert_select "input[name=?]", "product[print_on_menu]"

      assert_select "input[name=?]", "product[active]"

      assert_select "input[name=?]", "product[category_id]"
    end
  end
end
