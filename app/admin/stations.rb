# frozen_string_literal: true

ActiveAdmin.register Station do
  menu parent: "Dienstplanung", priority: 2, label: "Stationen"

  permit_params :name, :position, :active, :default_enabled
  config.sort_order = "position_asc"

  scope :all, default: true
  scope :active
  scope :defaults

  index do
    id_column
    column :position
    column :name
    column :active
    column :default_enabled
    column("Verwendet") { |station| station.work_schedule_day_stations.count }
    actions
  end

  filter :name
  filter :active
  filter :default_enabled

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :name
      f.input :position
      f.input :active
      f.input :default_enabled, label: "Bei neuen Tagen standardmäßig aktiv"
    end
    f.actions
  end
end
