require "rails_helper"

RSpec.describe ProductFamiliesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/product_families").to route_to("product_families#index")
    end

    it "routes to #new" do
      expect(get: "/product_families/new").to route_to("product_families#new")
    end

    it "routes to #show" do
      expect(get: "/product_families/1").to route_to("product_families#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/product_families/1/edit").to route_to("product_families#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/product_families").to route_to("product_families#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/product_families/1").to route_to("product_families#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/product_families/1").to route_to("product_families#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/product_families/1").to route_to("product_families#destroy", id: "1")
    end
  end
end
