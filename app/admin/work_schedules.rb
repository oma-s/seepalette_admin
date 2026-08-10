# frozen_string_literal: true

ActiveAdmin.register WorkSchedule do
  menu parent: "Users", priority: 3, label: "Work Schedules"

  permit_params :title, :starts_on, :ends_on, :status, :notes,
    work_schedule_days_attributes: [
      :id, :date, :title, :notes, :_destroy,
      {work_shifts_attributes: [:id, :user_id, :position, :starts_at, :ends_at, :break_minutes, :notes, :_destroy]}
    ]

  scope :all, default: true
  scope :draft
  scope :published

  filter :title
  filter :status, as: :select, collection: WorkSchedule.statuses
  filter :starts_on
  filter :ends_on
  filter :created_at

  controller do
    def scoped_collection
      super.includes(work_schedule_days: {work_shifts: :user})
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :period do |schedule|
      "#{l(schedule.starts_on)} - #{l(schedule.ends_on)}"
    end
    column :status do |schedule|
      status_tag schedule.status
    end
    column("Days") { |schedule| schedule.work_schedule_days.size }
    column("Shifts") { |schedule| schedule.work_shifts.size }
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :title
      row :starts_on
      row :ends_on
      row(:status) { |schedule| status_tag schedule.status }
      row :notes
      row :created_at
      row :updated_at
    end

    resource.work_schedule_days.each do |schedule_day|
      panel schedule_day.to_s do
        table_for schedule_day.work_shifts do
          column :time do |shift|
            "#{l(shift.starts_at, format: :short)} - #{l(shift.ends_at, format: :short)}"
          end
          column :user do |shift|
            link_to shift.user.to_s, admin_user_path(shift.user)
          end
          column :position
          column :break_minutes
          column :duration do |shift|
            minutes = shift.duration_minutes
            "#{minutes / 60}h #{minutes % 60}min" if minutes
          end
          column :notes
          column do |shift|
            link_to "Edit", edit_admin_work_shift_path(shift)
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs "Schedule" do
      f.input :title
      f.input :starts_on
      f.input :ends_on
      f.input :status, as: :select, collection: WorkSchedule.statuses.keys.map { |status| [status.humanize, status] }
      f.input :notes
    end

    f.has_many :work_schedule_days, heading: "Schedule days", allow_destroy: true, new_record: "Add schedule day" do |day|
      day.input :date
      day.input :title, hint: "Optional, for example Open-Air-Kino und Puppentheater"
      day.input :notes

      day.has_many :work_shifts, heading: "Shifts", allow_destroy: true, new_record: "Add shift" do |shift|
        shift.input :user, collection: User.order(:given_name, :family_name)
        shift.input :position, hint: "For example Bar, Küche 1, Runner or CvD"
        shift.input :starts_at
        shift.input :ends_at
        shift.input :break_minutes
        shift.input :notes
      end
    end

    f.actions
  end
end
