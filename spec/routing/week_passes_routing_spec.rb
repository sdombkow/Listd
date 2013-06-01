require "spec_helper"

describe WeekPassesController do
  describe "routing" do

    it "routes to #index" do
      get("/week_passes").should route_to("week_passes#index")
    end

    it "routes to #new" do
      get("/week_passes/new").should route_to("week_passes#new")
    end

    it "routes to #show" do
      get("/week_passes/1").should route_to("week_passes#show", :id => "1")
    end

    it "routes to #edit" do
      get("/week_passes/1/edit").should route_to("week_passes#edit", :id => "1")
    end

    it "routes to #create" do
      post("/week_passes").should route_to("week_passes#create")
    end

    it "routes to #update" do
      put("/week_passes/1").should route_to("week_passes#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/week_passes/1").should route_to("week_passes#destroy", :id => "1")
    end

  end
end
