class CreateWorkSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :work_schedules do |t|
      t.string :title, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :work_schedules, :status
    add_index :work_schedules, [:starts_on, :ends_on]

    create_table :work_schedule_days do |t|
      t.references :work_schedule, null: false, foreign_key: true
      t.date :date, null: false
      t.string :title
      t.text :notes

      t.timestamps
    end

    add_index :work_schedule_days, [:work_schedule_id, :date], unique: true

    create_table :work_shifts do |t|
      t.references :work_schedule_day, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :position, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :break_minutes, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :work_shifts, [:work_schedule_day_id, :starts_at]
    add_index :work_shifts, [:user_id, :starts_at, :ends_at]
  end
end
