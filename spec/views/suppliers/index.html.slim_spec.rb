require "rails_helper"

RSpec.describe "suppliers/index", type: :view do
  before(:each) do
    assign(:suppliers, [
      Supplier.create!(
        title: "Title",
        contact_email: "supplier@example.com",
        contact_phone: "Contact Phone",
        personal_contact_name: "Personal Contact Name",
        preffered_time_to_order: "Preffered Time To Order"
      ),
      Supplier.create!(
        title: "Title",
        contact_email: "supplier@example.com",
        contact_phone: "Contact Phone",
        personal_contact_name: "Personal Contact Name",
        preffered_time_to_order: "Preffered Time To Order"
      )
    ])
  end

  it "renders a list of suppliers" do
    render
    cell_selector = "div>p"
    assert_select cell_selector, text: Regexp.new("Title"), count: 2
    assert_select cell_selector, text: Regexp.new("supplier@example.com"), count: 2
    assert_select cell_selector, text: Regexp.new("Contact Phone"), count: 2
    assert_select cell_selector, text: Regexp.new("Personal Contact Name"), count: 2
    assert_select cell_selector, text: Regexp.new("Preffered Time To Order"), count: 2
  end
end
