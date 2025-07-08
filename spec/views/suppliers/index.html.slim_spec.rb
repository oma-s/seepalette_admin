require 'rails_helper'

RSpec.describe "suppliers/index", type: :view do
  before(:each) do
    assign(:suppliers, [
      Supplier.create!(
        title: "Title",
        contact_email: "Contact Email",
        contact_phone: "Contact Phone",
        personal_contact_name: "Personal Contact Name",
        preffered_time_to_order: "Preffered Time To Order"
      ),
      Supplier.create!(
        title: "Title",
        contact_email: "Contact Email",
        contact_phone: "Contact Phone",
        personal_contact_name: "Personal Contact Name",
        preffered_time_to_order: "Preffered Time To Order"
      )
    ])
  end

  it "renders a list of suppliers" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Title".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Contact Email".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Contact Phone".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Personal Contact Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Preffered Time To Order".to_s), count: 2
  end
end
