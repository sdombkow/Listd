require "spec_helper"

describe TicketSetsController do
  describe "routing" do

    it "routes to #index" do
      get("/ticket_sets").should route_to("ticket_sets#index")
    end

    it "routes to #new" do
      get("/ticket_sets/new").should route_to("ticket_sets#new")
    end

    it "routes to #show" do
      get("/ticket_sets/1").should route_to("ticket_sets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/ticket_sets/1/edit").should route_to("ticket_sets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/ticket_sets").should route_to("ticket_sets#create")
    end

    it "routes to #update" do
      put("/ticket_sets/1").should route_to("ticket_sets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/ticket_sets/1").should route_to("ticket_sets#destroy", :id => "1")
    end

  end
end
