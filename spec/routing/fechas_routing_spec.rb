require "spec_helper"

describe FechasController do
  describe "routing" do

    it "routes to #index" do
      get("/fechas").should route_to("fechas#index")
    end

    it "routes to #new" do
      get("/fechas/new").should route_to("fechas#new")
    end

    it "routes to #show" do
      get("/fechas/1").should route_to("fechas#show", :id => "1")
    end

    it "routes to #edit" do
      get("/fechas/1/edit").should route_to("fechas#edit", :id => "1")
    end

    it "routes to #create" do
      post("/fechas").should route_to("fechas#create")
    end

    it "routes to #update" do
      put("/fechas/1").should route_to("fechas#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/fechas/1").should route_to("fechas#destroy", :id => "1")
    end

  end
end
