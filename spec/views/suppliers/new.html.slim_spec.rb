require 'rails_helper'

RSpec.describe "suppliers/new", type: :view do
  before(:each) do
    assign(:supplier, Supplier.new(
      title: "MyString",
      contact_email: "MyString",
      contact_phone: "MyString",
      personal_contact_name: "MyString",
      preffered_time_to_order: "MyString"
    ))
  end

  it "renders new supplier form" do
    render

    assert_select "form[action=?][method=?]", suppliers_path, "post" do

      assert_select "input[name=?]", "supplier[title]"

      assert_select "input[name=?]", "supplier[contact_email]"

      assert_select "input[name=?]", "supplier[contact_phone]"

      assert_select "input[name=?]", "supplier[personal_contact_name]"

      assert_select "input[name=?]", "supplier[preffered_time_to_order]"
    end
  end
end
