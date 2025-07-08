class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :title, null: false
      t.text :description
      t.references :product_family, null: true, foreign_key: true

      t.timestamps
    end
  end
end
