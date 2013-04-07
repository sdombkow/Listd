require "spec_helper"

describe DiaController do
  describe "routing" do

    it "routes to #index" do
      get("/dia").should route_to("dia#index")
    end

    it "routes to #new" do
      get("/dia/new").should route_to("dia#new")
    end

    it "routes to #show" do
      get("/dia/1").should route_to("dia#show", :id => "1")
    end

    it "routes to #edit" do
      get("/dia/1/edit").should route_to("dia#edit", :id => "1")
    end

    it "routes to #create" do
      post("/dia").should route_to("dia#create")
    end

    it "routes to #update" do
      put("/dia/1").should route_to("dia#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/dia/1").should route_to("dia#destroy", :id => "1")
    end

  end
end
