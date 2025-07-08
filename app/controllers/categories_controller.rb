class CategoriesController < InheritedResources::Base

  private

    def category_params
      params.require(:category).permit(:title, :product_family_id)
    end

end
