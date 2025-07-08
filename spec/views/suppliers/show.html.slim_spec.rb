require 'rails_helper'

RSpec.describe "suppliers/show", type: :view do
  before(:each) do
    assign(:supplier, Supplier.create!(
      title: "Title",
      contact_email: "Contact Email",
      contact_phone: "Contact Phone",
      personal_contact_name: "Personal Contact Name",
      preffered_time_to_order: "Preffered Time To Order"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Contact Email/)
    expect(rendered).to match(/Contact Phone/)
    expect(rendered).to match(/Personal Contact Name/)
    expect(rendered).to match(/Preffered Time To Order/)
  end
end
