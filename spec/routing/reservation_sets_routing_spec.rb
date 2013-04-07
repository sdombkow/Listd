require "spec_helper"

describe ReservationSetsController do
  describe "routing" do

    it "routes to #index" do
      get("/reservation_sets").should route_to("reservation_sets#index")
    end

    it "routes to #new" do
      get("/reservation_sets/new").should route_to("reservation_sets#new")
    end

    it "routes to #show" do
      get("/reservation_sets/1").should route_to("reservation_sets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/reservation_sets/1/edit").should route_to("reservation_sets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/reservation_sets").should route_to("reservation_sets#create")
    end

    it "routes to #update" do
      put("/reservation_sets/1").should route_to("reservation_sets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/reservation_sets/1").should route_to("reservation_sets#destroy", :id => "1")
    end

  end
end
