class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.text :menu_description
      t.decimal :ekp
      t.decimal :uvp
      t.decimal :vkp
      t.string :stock_unit
      t.integer :stock_target
      t.boolean :print_on_menu
      t.boolean :active, default: false
      t.references :category, null: true, foreign_key: true

      t.timestamps
    end
  end
end
