require 'rails_helper'

RSpec.describe "product_families/edit", type: :view do
  let(:product_family) {
    ProductFamily.create!(
      title: "MyString"
    )
  }

  before(:each) do
    assign(:product_family, product_family)
  end

  it "renders the edit product_family form" do
    render

    assert_select "form[action=?][method=?]", product_family_path(product_family), "post" do

      assert_select "input[name=?]", "product_family[title]"
    end
  end
end
