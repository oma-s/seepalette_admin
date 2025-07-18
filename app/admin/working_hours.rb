ActiveAdmin.register WorkingHour do
  belongs_to :user, optional: true

  # Specify parameters which should be permitted for assignment
  permit_params :date, :start_at, :end_at, :break_minutes, :duration_minutes, :user_id

  # or consider:
  #
  # permit_params do
  #   permitted = [:date, :start_at, :end_at, :break_minutes, :duration_minutes, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # For security, limit the actions that should be available
  actions :all, except: []

  # Add or remove filters to toggle their visibility
  filter :id
  filter :date
  filter :start_at
  filter :end_at
  filter :break_minutes
  filter :duration_minutes
  filter :user
  filter :created_at
  filter :updated_at

  # Add or remove columns to toggle their visibility in the index action
  index do
    selectable_column
    id_column
    column :date
    column :start_at
    column :end_at
    column :break_minutes
    column :duration_minutes
    column :duration do |wh|
      if wh.duration_minutes
        hours = wh.duration_minutes / 60
        minutes = wh.duration_minutes % 60
        "#{hours}h #{minutes}min"
      end
    end
    column :user do |wh|
      if wh.user
        link_to wh.user.to_s, admin_user_path(wh.user)
      end
    end
    column :created_at
    column :updated_at
    actions

    # Add total duration summary below the table
    div style: 'padding: 20px; font-weight: bold;' do
      total_minutes = collection.sum(:duration_minutes)
      hours = total_minutes / 60
      minutes = total_minutes % 60
      "Hours total: #{hours}h #{minutes}min"
    end
  end

  # Add or remove rows to toggle their visibility in the show action
  show do
    attributes_table_for(resource) do
      row :id
      row :date
      row :start_at
      row :end_at
      row :break_minutes
      row :duration_minutes
      row :duration do |wh|
        if wh.duration_minutes
          hours = wh.duration_minutes / 60
          minutes = wh.duration_minutes % 60
          "#{hours}h #{minutes}min"
        end
      end
      row :user do |wh|
        if wh.user
          link_to wh.user.to_s, admin_user_path(wh.user)
        end
      end
      row :created_at
      row :updated_at
    end
  end

  # Add or remove fields to toggle their visibility in the form
  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :start_at
      f.input :end_at
      f.input :break_minutes
      f.input :user
    end
    f.actions
  end
end
