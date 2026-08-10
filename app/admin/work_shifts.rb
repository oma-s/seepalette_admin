# frozen_string_literal: true

ActiveAdmin.register WorkShift do
  menu parent: "Users", priority: 4, label: "Work Shifts"

  belongs_to :work_schedule_day, optional: true

  permit_params :work_schedule_day_id, :user_id, :position, :starts_at, :ends_at, :break_minutes, :notes

  filter :work_schedule_day
  filter :user
  filter :position
  filter :starts_at
  filter :ends_at

  controller do
    def scoped_collection
      super.includes(:user, work_schedule_day: :work_schedule)
    end
  end

  index do
    selectable_column
    id_column
    column :schedule do |shift|
      link_to shift.work_schedule.to_s, admin_work_schedule_path(shift.work_schedule)
    end
    column :day do |shift|
      link_to shift.work_schedule_day.to_s, admin_work_schedule_day_path(shift.work_schedule_day)
    end
    column :user do |shift|
      link_to shift.user.to_s, admin_user_path(shift.user)
    end
    column :position
    column :starts_at
    column :ends_at
    column :break_minutes
    column :duration do |shift|
      minutes = shift.duration_minutes
      "#{minutes / 60}h #{minutes % 60}min" if minutes
    end
    actions
  end

  show do
    attributes_table do
      row(:work_schedule) { |shift| link_to shift.work_schedule.to_s, admin_work_schedule_path(shift.work_schedule) }
      row :work_schedule_day
      row(:user) { |shift| link_to shift.user.to_s, admin_user_path(shift.user) }
      row :position
      row :starts_at
      row :ends_at
      row :break_minutes
      row :duration do |shift|
        minutes = shift.duration_minutes
        "#{minutes / 60}h #{minutes % 60}min" if minutes
      end
      row :notes
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :work_schedule_day
      f.input :user, collection: User.order(:given_name, :family_name)
      f.input :position
      f.input :starts_at
      f.input :ends_at
      f.input :break_minutes
      f.input :notes
    end
    f.actions
  end
end
