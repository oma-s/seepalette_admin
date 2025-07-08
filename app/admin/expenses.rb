ActiveAdmin.register Expense do
  belongs_to :user, optional: true

  # Specify parameters which should be permitted for assignment
  permit_params :user_id, :date, :start_address, :end_address, :purpose, :km, :factor

  # or consider:
  #
  # permit_params do
  #   permitted = [:user_id, :date, :start_address, :end_address, :km, :factor]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # For security, limit the actions that should be available
  actions :all, except: []

  # Add or remove filters to toggle their visibility
  filter :id
  filter :user
  filter :date
  filter :start_address
  filter :end_address
  filter :km
  filter :factor
  filter :created_at
  filter :updated_at

  # Add or remove columns to toggle their visibility in the index action
  index do
    selectable_column
    id_column
    column :user do |expense|
      auto_link(expense.user, expense.user.to_s)
    end
    column :date
    column :start_address
    column :end_address
    column :km
    column :factor
    column :created_at
    column :updated_at
    actions
  end

  # Add or remove rows to toggle their visibility in the show action
  show do
    attributes_table_for(resource) do
      row :id
      row :user do |expense|
        auto_link(expense.user, expense.user.to_s)
      end
      row :date
      row :start_address
      row :end_address
      row :purpose
      row :km
      row :factor
      row :created_at
      row :updated_at
    end
  end

  # Add or remove fields to toggle their visibility in the form
  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    home_address = resource.user&.addresses&.first&.to_s
    f.inputs do
      f.input :user
      f.input :date
      f.input :start_address, input_html: { value: home_address || '' }
      f.input :end_address, input_html: { value: home_address || '' }
      f.input :purpose, as: :text, input_html: { rows: 3 }
      f.input :km
      f.input :factor, as: :number, step: 0.01, input_html: { min: 0.1, value: 0.3 }
    end
    f.actions
  end
end
