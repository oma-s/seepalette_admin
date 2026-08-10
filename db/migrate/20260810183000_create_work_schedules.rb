# frozen_string_literal: true

class CreateWorkSchedules < ActiveRecord::Migration[8.1]
  DEFAULT_STATIONS = ["Brötchen", "Küche", "Küche 1", "Küche 2", "Bar", "Runner", "CvD", "Aushilfe"].freeze

  def up
    add_column :users, :schedulable, :boolean, null: false, default: true
    add_index :users, :schedulable

    create_table :stations do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.boolean :default_enabled, null: false, default: false
      t.timestamps
    end
    add_index :stations, :name, unique: true
    add_index :stations, [:active, :default_enabled, :position]

    create_table :work_schedules do |t|
      t.string :title, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.text :notes
      t.datetime :content_updated_at, null: false
      t.timestamps
    end
    add_index :work_schedules, [:starts_on, :ends_on]

    create_table :work_schedule_days do |t|
      t.references :work_schedule, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :grid_start_minute, null: false, default: 420
      t.integer :grid_end_minute, null: false, default: 1_440
      t.timestamps
    end
    add_index :work_schedule_days, [:work_schedule_id, :date], unique: true

    create_table :work_schedule_day_stations do |t|
      t.references :work_schedule_day, null: false, foreign_key: true
      t.references :station, null: true, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :work_schedule_day_stations, [:work_schedule_day_id, :name], unique: true, name: "idx_day_stations_unique_name"
    add_index :work_schedule_day_stations, [:work_schedule_day_id, :station_id], unique: true, where: "station_id IS NOT NULL", name: "idx_day_stations_unique_catalog_station"

    create_table :day_notices do |t|
      t.references :work_schedule_day, null: false, foreign_key: true
      t.text :text, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :day_notices, [:work_schedule_day_id, :position]

    create_table :work_shifts do |t|
      t.references :work_schedule_day_station, null: false, foreign_key: true, index: {name: "idx_work_shifts_on_day_station"}
      t.references :user, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :break_minutes, null: false, default: 0
      t.text :notes
      t.timestamps
    end
    add_index :work_shifts, [:work_schedule_day_station_id, :starts_at], name: "idx_work_shifts_station_start"
    add_index :work_shifts, [:user_id, :starts_at, :ends_at]

    create_table :work_schedule_publications do |t|
      t.references :work_schedule, null: false, foreign_key: true
      t.references :published_by, null: false, foreign_key: {to_table: :users}
      t.integer :revision, null: false
      t.datetime :source_updated_at, null: false
      t.datetime :published_at, null: false
      t.json :payload, null: false
      t.timestamps
    end
    add_index :work_schedule_publications, [:work_schedule_id, :revision], unique: true, name: "idx_schedule_publications_revision"

    seed_default_stations
    grant_default_admin_role
  end

  def down
    drop_table :work_schedule_publications
    drop_table :work_shifts
    drop_table :day_notices
    drop_table :work_schedule_day_stations
    drop_table :work_schedule_days
    drop_table :work_schedules
    drop_table :stations
    remove_index :users, :schedulable
    remove_column :users, :schedulable
  end

  private

  def seed_default_stations
    now = Time.current
    DEFAULT_STATIONS.each_with_index do |name, position|
      execute <<~SQL.squish
        INSERT INTO stations (name, position, active, default_enabled, created_at, updated_at)
        VALUES (#{quote(name)}, #{position}, #{quoted_true}, #{quoted_true}, #{quote(now)}, #{quote(now)})
      SQL
    end
  end

  def grant_default_admin_role
    user_id = select_value("SELECT id FROM users WHERE email = #{quote("admin@example.com")} LIMIT 1")
    return unless user_id

    role_id = select_value("SELECT id FROM roles WHERE name = 'admin' AND resource_type IS NULL AND resource_id IS NULL LIMIT 1")
    unless role_id
      now = Time.current
      execute <<~SQL.squish
        INSERT INTO roles (name, resource_type, resource_id, created_at, updated_at)
        VALUES ('admin', NULL, NULL, #{quote(now)}, #{quote(now)})
      SQL
      role_id = select_value("SELECT id FROM roles WHERE name = 'admin' AND resource_type IS NULL AND resource_id IS NULL LIMIT 1")
    end

    execute <<~SQL.squish
      INSERT INTO users_roles (user_id, role_id)
      SELECT #{user_id}, #{role_id}
      WHERE NOT EXISTS (
        SELECT 1 FROM users_roles WHERE user_id = #{user_id} AND role_id = #{role_id}
      )
    SQL
  end

  def quote(value)
    connection.quote(value)
  end

  def quoted_true
    connection.quoted_true
  end
end
