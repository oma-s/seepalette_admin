# frozen_string_literal: true

ActiveAdmin.register WorkScheduleDay do
  menu false

  belongs_to :work_schedule, optional: true

  permit_params :work_schedule_id, :date, :title, :notes,
    work_shifts_attributes: [:id, :user_id, :position, :starts_at, :ends_at, :break_minutes, :notes, :_destroy]

  filter :work_schedule
  filter :date
  filter :title

  index do
    id_column
    column :work_schedule
    column :date
    column :title
    column("Shifts") { |day| day.work_shifts.size }
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs "Schedule day" do
      f.input :work_schedule
      f.input :date
      f.input :title
      f.input :notes
    end

    f.has_many :work_shifts, heading: "Shifts", allow_destroy: true, new_record: "Add shift" do |shift|
      shift.input :user, collection: User.order(:given_name, :family_name)
      shift.input :position
      shift.input :starts_at
      shift.input :ends_at
      shift.input :break_minutes
      shift.input :notes
    end

    f.actions
  end
end
