class ProductsController < InheritedResources::Base

  private

    def product_params
      params.require(:product).permit(:title, :menu_description, :ekp, :uvp, :vkp, :stock_unit, :stock_target, :print_on_menu, :active, :category_id)
    end

end
