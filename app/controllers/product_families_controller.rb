class ProductFamiliesController < InheritedResources::Base

  private

    def product_family_params
      params.require(:product_family).permit(:title)
    end

end
