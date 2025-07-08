require 'rails_helper'

RSpec.describe "product_families/new", type: :view do
  before(:each) do
    assign(:product_family, ProductFamily.new(
      title: "MyString"
    ))
  end

  it "renders new product_family form" do
    render

    assert_select "form[action=?][method=?]", product_families_path, "post" do

      assert_select "input[name=?]", "product_family[title]"
    end
  end
end
