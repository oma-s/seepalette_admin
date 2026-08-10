require "rails_helper"

RSpec.describe "categories/index", type: :view do
  before(:each) do
    assign(:categories, [
      Category.create!(
        title: "Title",
        product_family: nil
      ),
      Category.create!(
        title: "Title",
        product_family: nil
      )
    ])
  end

  it "renders a list of categories" do
    render
    assert_select "#categories > div", count: 2
    assert_select "#categories > div p", text: /Title:\s*Title/, count: 2
  end
end
