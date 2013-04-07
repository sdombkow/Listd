require "spec_helper"

describe DealSetsController do
  describe "routing" do

    it "routes to #index" do
      get("/deal_sets").should route_to("deal_sets#index")
    end

    it "routes to #new" do
      get("/deal_sets/new").should route_to("deal_sets#new")
    end

    it "routes to #show" do
      get("/deal_sets/1").should route_to("deal_sets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/deal_sets/1/edit").should route_to("deal_sets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/deal_sets").should route_to("deal_sets#create")
    end

    it "routes to #update" do
      put("/deal_sets/1").should route_to("deal_sets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/deal_sets/1").should route_to("deal_sets#destroy", :id => "1")
    end

  end
end
