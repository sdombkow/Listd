require 'spec_helper'

describe AdminController do

  describe "GET 'customers'" do
    it "returns http success" do
      get 'customers'
      response.should be_success
    end
  end

  describe "GET 'partners'" do
    it "returns http success" do
      get 'partners'
      response.should be_success
    end
  end

end
