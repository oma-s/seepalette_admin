ActiveAdmin.register Product do
  belongs_to :supplier, optional: true
  belongs_to :category, optional: true

  # Specify parameters which should be permitted for assignment
  permit_params :title, :menu_description, :ekp, :uvp, :vkp, :stock_unit, :stock_target, :print_on_menu, :active,
                :category_id

  # or consider:
  #
  # permit_params do
  #   permitted = [:title, :menu_description, :ekp, :uvp, :vkp, :stock_unit, :stock_target, :print_on_menu, :active, :category_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # For security, limit the actions that should be available
  actions :all, except: []

  # Add or remove filters to toggle their visibility
  filter :id
  filter :title
  filter :menu_description
  filter :ekp
  filter :uvp
  filter :vkp
  filter :stock_unit
  filter :stock_target
  filter :print_on_menu
  filter :active
  filter :category
  filter :created_at
  filter :updated_at

  # Add or remove columns to toggle their visibility in the index action
  index do
    selectable_column
    id_column
    column :title
    column :menu_description
    column :ekp
    column :uvp
    column :vkp
    column :stock_unit
    column :stock_target
    column :print_on_menu
    column :active
    column :category
    column :created_at
    column :updated_at
    actions
  end

  # Add or remove rows to toggle their visibility in the show action
  show do
    attributes_table_for(resource) do
      row :id
      row :title
      row :menu_description
      row :ekp
      row :uvp
      row :vkp
      row :stock_unit
      row :stock_target
      row :print_on_menu
      row :active
      row :category
      row :created_at
      row :updated_at
    end
  end

  # Add or remove fields to toggle their visibility in the form
  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :supplier
      f.input :title
      f.input :menu_description, as: :text, input_html: { rows: 3 }
      f.input :ekp
      f.input :uvp
      f.input :vkp
      f.input :stock_unit
      f.input :stock_target
      f.input :print_on_menu
      f.input :active
      f.input :category
    end
    f.actions
  end
end
