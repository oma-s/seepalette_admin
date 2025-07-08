ActiveAdmin.register Supplier do
  # Specify parameters which should be permitted for assignment
  permit_params :title, :description, :website, :contact_email, :contact_phone, :personal_contact_name,
                :preffered_time_to_order

  # or consider:
  #
  # permit_params do
  #   permitted = [:title, :description, :website, :contact_email, :contact_phone, :personal_contact_name, :preffered_time_to_order]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # For security, limit the actions that should be available
  actions :all, except: []

  # Add or remove filters to toggle their visibility
  filter :id
  filter :title
  filter :description
  filter :website
  filter :contact_email
  filter :contact_phone
  filter :personal_contact_name
  filter :preffered_time_to_order
  filter :created_at
  filter :updated_at

  # Add or remove columns to toggle their visibility in the index action
  index do
    selectable_column
    id_column
    column :title
    column :description
    column :website
    column :contact_email
    column :contact_phone
    column :personal_contact_name
    column :preffered_time_to_order
    column :created_at
    column :updated_at
    actions
  end

  # Add or remove rows to toggle their visibility in the show action
  show do
    attributes_table_for(resource) do
      row :id
      row :title
      row :description
      row :website
      row :contact_email
      row :contact_phone
      row :personal_contact_name
      row :preffered_time_to_order
      row :created_at
      row :updated_at
    end
  end

  # Add or remove fields to toggle their visibility in the form
  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :title
      f.input :description
      f.input :website
      f.input :contact_email
      f.input :contact_phone
      f.input :personal_contact_name
      f.input :preffered_time_to_order
    end
    f.actions
  end
end
