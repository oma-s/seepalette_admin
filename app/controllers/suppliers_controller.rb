class SuppliersController < InheritedResources::Base

  private

    def supplier_params
      params.require(:supplier).permit(:title, :contact_email, :contact_phone, :personal_contact_name, :preffered_time_to_order)
    end

end
