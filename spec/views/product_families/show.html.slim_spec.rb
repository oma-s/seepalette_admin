require 'rails_helper'

RSpec.describe "product_families/show", type: :view do
  before(:each) do
    assign(:product_family, ProductFamily.create!(
      title: "Title"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
  end
end
