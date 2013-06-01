require "spec_helper"

describe WeeklyPassesController do
  describe "routing" do

    it "routes to #index" do
      get("/weekly_passes").should route_to("weekly_passes#index")
    end

    it "routes to #new" do
      get("/weekly_passes/new").should route_to("weekly_passes#new")
    end

    it "routes to #show" do
      get("/weekly_passes/1").should route_to("weekly_passes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/weekly_passes/1/edit").should route_to("weekly_passes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/weekly_passes").should route_to("weekly_passes#create")
    end

    it "routes to #update" do
      put("/weekly_passes/1").should route_to("weekly_passes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/weekly_passes/1").should route_to("weekly_passes#destroy", :id => "1")
    end

  end
end
