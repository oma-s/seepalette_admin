# frozen_string_literal: true

class RefineWorkSchedulePlanner < ActiveRecord::Migration[8.1]
  SCHEDULE_COLORS = %w[indigo blue cyan teal green lime amber orange rose fuchsia violet slate].freeze

  def up
    add_column :users, :schedule_color, :string
    select_values("SELECT id FROM users ORDER BY id").each_with_index do |id, index|
      color = connection.quote(SCHEDULE_COLORS[index % SCHEDULE_COLORS.length])
      execute "UPDATE users SET schedule_color = #{color} WHERE id = #{connection.quote(id)}"
    end
    change_column_null :users, :schedule_color, false

    add_column :day_notices, :severity, :string, null: false, default: "info"
    remove_index :day_notices, name: "index_day_notices_on_work_schedule_day_id_and_position"
    remove_column :day_notices, :position, :integer

    remove_column :work_shifts, :break_minutes, :integer
  end

  def down
    add_column :work_shifts, :break_minutes, :integer, null: false, default: 0

    add_column :day_notices, :position, :integer, null: false, default: 0
    add_index :day_notices, [:work_schedule_day_id, :position]
    remove_column :day_notices, :severity, :string

    remove_column :users, :schedule_color, :string
  end
end
