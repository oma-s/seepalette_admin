class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.string :start_address, null: false
      t.string :end_address, null: false
      t.text :purpose, null: false
      t.integer :km, null: false
      t.decimal :factor, null: false, precision: 3, scale: 2

      t.timestamps
    end
  end
end
