# frozen_string_literal: true

ActiveAdmin.register Announcement do
  menu parent: "Mitarbeiterportal", priority: 1, label: "Hinweise"

  permit_params :title, :body, :severity, :active, :visible_from, :visible_until, :priority

  config.batch_actions = false

  scope :all, default: true
  scope("Aktuell sichtbar") { |scope| scope.visible_at }

  filter :title
  filter :severity, as: :select, collection: Announcement::SEVERITIES
  filter :active
  filter :visible_from
  filter :visible_until

  index do
    id_column
    column :title
    column("Stufe") { |announcement| status_tag announcement.severity }
    column :active
    column :visible_from
    column :visible_until
    column :priority
    actions
  end

  show do
    attributes_table do
      row :title
      row :body
      row(:severity) { |announcement| status_tag announcement.severity }
      row :active
      row :visible_from
      row :visible_until
      row :priority
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs "Hinweis" do
      f.input :title
      f.input :body, as: :text, input_html: {rows: 6}
      f.input :severity, as: :select, collection: Announcement::SEVERITIES
      f.input :active
      f.input :visible_from
      f.input :visible_until
      f.input :priority, hint: "Höhere Werte werden zuerst angezeigt."
    end
    f.actions
  end
end
