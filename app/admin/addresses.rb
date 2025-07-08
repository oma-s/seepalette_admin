ActiveAdmin.register Address do
  # Specify parameters which should be permitted for assignment
  permit_params :address_line1, :address_line2, :zip, :city, :addressable_type, :addressable_id

  # or consider:
  #
  # permit_params do
  #   permitted = [:address_line1, :address_line2, :zip, :city, :addressable_type, :addressable_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  # For security, limit the actions that should be available
  actions :all, except: []

  # Add or remove filters to toggle their visibility
  filter :id
  filter :address_line1
  filter :address_line2
  filter :zip
  filter :city
  filter :created_at
  filter :updated_at

  # Add or remove columns to toggle their visibility in the index action
  index do
    selectable_column
    id_column
    column :address_line1
    column :address_line2
    column :zip
    column :city
    column :addressable_type
    column :addressable do |address|
      if address.addressable
        auto_link(address.addressable, address.addressable.to_s)
      else
        'N/A'
      end
    end
    column :created_at
    column :updated_at
    actions
  end

  # Add or remove rows to toggle their visibility in the show action
  show do
    attributes_table_for(resource) do
      row :id
      row :address_line1
      row :address_line2
      row :zip
      row :city
      row :addressable_type
      row :addressable do |address|
        if address.addressable
          auto_link(address.addressable, address.addressable.to_s)
        else
          'N/A'
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
      f.input :address_line1
      f.input :address_line2
      f.input :zip
      f.input :city
      f.input :addressable_type, as: :select, collection: %w[User Supplier], include_blank: false

      # For addressable_id, you must give a collection depending on addressable_type
      # Let's just show all users and suppliers for now
      addressable_collection =
        case f.object.addressable_type
        when 'User'
          User.all.map { |u| [u.to_s, u.id] }
        when 'Supplier'
          Supplier.all.map { |s| [s.to_s, s.id] }
        else
          []
        end

      f.input :addressable_id, as: :select, collection: addressable_collection
    end
    f.actions
  end
end
