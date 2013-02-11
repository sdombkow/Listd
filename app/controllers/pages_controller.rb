class PagesController < ApplicationController

	def facebook_activity
	end
	
	def download
      send_file 'public/data/listd_product_summary.pdf'
  end
  
  def customers
      #send_file 'public/data/listd_product_summary.pdf'
  end
  
end