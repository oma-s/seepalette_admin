class CreateWorkingHours < ActiveRecord::Migration[8.0]
  def change
    create_table :working_hours do |t|
      t.date :date
      t.datetime :start_at
      t.datetime :end_at
      t.integer :break_minutes
      t.integer :duration_minutes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
