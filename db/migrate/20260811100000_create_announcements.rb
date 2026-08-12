# frozen_string_literal: true

class CreateAnnouncements < ActiveRecord::Migration[8.1]
  def change
    create_table :announcements do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.string :severity, null: false, default: "info"
      t.boolean :active, null: false, default: true
      t.datetime :visible_from
      t.datetime :visible_until
      t.integer :priority, null: false, default: 0

      t.timestamps
    end

    add_index :announcements, [:active, :visible_from, :visible_until], name: "idx_announcements_visibility"
    add_index :announcements, [:priority, :created_at]

    change_column_default :expenses, :factor, from: nil, to: 0.3
  end
end
