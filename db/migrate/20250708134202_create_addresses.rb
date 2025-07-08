class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :address_line1, null: false
      t.string :address_line2
      t.string :zip, null: false
      t.string :city, null: false
      t.references :addressable, polymorphic: true, null: true

      t.timestamps
    end
  end
end
