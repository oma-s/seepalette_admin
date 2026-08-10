# frozen_string_literal: true

ActiveAdmin.register User do
  menu parent: "Users", priority: 1, label: "Users"

  permit_params :given_name, :family_name, :email, :password, :password_confirmation, :schedulable, :schedule_color, :admin_role

  config.batch_actions = false

  controller do
    def update
      with_blocking_on_default_admin_user do
        super
      end
    end

    def destroy
      with_blocking_on_default_admin_user do
        super
      end
    end

    private

    def with_blocking_on_default_admin_user
      if resource.email == User::DEFAULT_EMAIL
        flash[:alert] = "The default admin user cannot be modified."
        redirect_back_or_to(admin_users_path)
      else
        yield
      end
    end
  end

  index do
    id_column
    column :given_name
    column :family_name
    column :email
    column :schedulable
    column("Planfarbe") do |user|
      span User::SCHEDULE_COLORS.fetch(user.schedule_color), class: "schedule-color-label schedule-color-label--#{user.schedule_color}"
    end
    column("Admin") { |user| user.admin? }
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  show do
    attributes_table do
      row :id
      row :given_name
      row :family_name
      row :email
      row :schedulable
      row("Planfarbe") do |user|
        span User::SCHEDULE_COLORS.fetch(user.schedule_color), class: "schedule-color-label schedule-color-label--#{user.schedule_color}"
      end
      row("Admin") { |user| user.admin? }
      row :current_sign_in_at
      row :sign_in_count
      row :created_at
      row :updated_at
    end

    # Add panel for working hours
    panel "Working Hours" do
      table_for resource.working_hours do
        column :id do |wh|
          link_to wh.id, admin_user_working_hour_path(resource, wh)
        end
        column :start_at
        column :end_at
        column :break_minutes
      end

      div do
        link_to "New Working Hour", new_admin_user_working_hour_path(resource), class: "button"
      end
    end

    panel "Planned Shifts" do
      table_for resource.work_shifts.chronological.includes(work_schedule_day_station: {work_schedule_day: :work_schedule}) do
        column :schedule do |shift|
          link_to shift.work_schedule.to_s, admin_work_schedule_path(shift.work_schedule)
        end
        column :day do |shift|
          shift.work_schedule_day.to_s
        end
        column("Station") { |shift| shift.work_schedule_day_station.name }
        column :starts_at
        column :ends_at
      end
    end

    # Add panel for expenses
    panel "Expenses" do
      table_for resource.expenses do
        column :id do |expense|
          link_to expense.id, admin_user_expense_path(resource, expense)
        end
        column :date
        column :start_address
        column :end_address
        column :purpose
        column :km
        column :factor
      end

      div do
        link_to "New Expense", new_admin_user_expense_path(resource), class: "button"
      end
    end

    # Add panel for addresses
    panel "Addresses" do
      table_for resource.addresses do
        column :id do |address|
          link_to address.id, admin_address_path(address)
        end
        column :address_line1
        column :address_line2
        column :zip
        column :city
      end

      div do
        link_to "New Address", new_admin_address_path(addressable_type: "User", addressable_id: resource.id),
          class: "button"
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :given_name, required: true
      f.input :family_name, required: true
      f.input :email
      f.input :schedulable, label: "Für Dienstpläne auswählbar"
      f.input :schedule_color,
        as: :radio,
        collection: User.schedule_color_options,
        label: "Farbe im Dienstplan",
        wrapper_html: {class: "schedule-color-picker"}
      f.input :admin_role, as: :boolean, label: "Adminzugriff"
      f.input :password
      f.input :password_confirmation, required: true
    end
    f.actions
  end
end
