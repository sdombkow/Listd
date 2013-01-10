class PagesController < ApplicationController

	def facebook_activity
	end
	
	def download
      send_file 'listd/public/data/listd_product_summary.zip', :x_sendfile=>true
  end
end