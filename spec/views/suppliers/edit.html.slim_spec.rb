require 'rails_helper'

RSpec.describe "suppliers/edit", type: :view do
  let(:supplier) {
    Supplier.create!(
      title: "MyString",
      contact_email: "MyString",
      contact_phone: "MyString",
      personal_contact_name: "MyString",
      preffered_time_to_order: "MyString"
    )
  }

  before(:each) do
    assign(:supplier, supplier)
  end

  it "renders the edit supplier form" do
    render

    assert_select "form[action=?][method=?]", supplier_path(supplier), "post" do

      assert_select "input[name=?]", "supplier[title]"

      assert_select "input[name=?]", "supplier[contact_email]"

      assert_select "input[name=?]", "supplier[contact_phone]"

      assert_select "input[name=?]", "supplier[personal_contact_name]"

      assert_select "input[name=?]", "supplier[preffered_time_to_order]"
    end
  end
end
