require 'spec_helper'

describe "WeeklyPasses" do
  describe "GET /weekly_passes" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get weekly_passes_path
      response.status.should be(200)
    end
  end
end
