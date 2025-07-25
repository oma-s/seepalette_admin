require "rails_helper"

RSpec.describe WorkingHoursController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/working_hours").to route_to("working_hours#index")
    end

    it "routes to #new" do
      expect(get: "/working_hours/new").to route_to("working_hours#new")
    end

    it "routes to #show" do
      expect(get: "/working_hours/1").to route_to("working_hours#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/working_hours/1/edit").to route_to("working_hours#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/working_hours").to route_to("working_hours#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/working_hours/1").to route_to("working_hours#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/working_hours/1").to route_to("working_hours#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/working_hours/1").to route_to("working_hours#destroy", id: "1")
    end
  end
end
