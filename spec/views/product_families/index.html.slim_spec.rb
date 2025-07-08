require 'rails_helper'

RSpec.describe "product_families/index", type: :view do
  before(:each) do
    assign(:product_families, [
      ProductFamily.create!(
        title: "Title"
      ),
      ProductFamily.create!(
        title: "Title"
      )
    ])
  end

  it "renders a list of product_families" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
  end
end
