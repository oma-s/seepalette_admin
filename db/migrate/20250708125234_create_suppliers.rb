class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :title, null: false
      t.string :description
      t.string :website
      t.string :contact_email
      t.string :contact_phone
      t.string :personal_contact_name
      t.string :preffered_time_to_order

      t.timestamps
    end
  end
end
