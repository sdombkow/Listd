class Api::V1::TasksController < ApplicationController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  # Just skip the authentication for now
  before_filter :authenticate_user!

  respond_to :json

  def index
    render :text => '{
  "success":true,
  "info":"ok",
  "data":{
          "bars":'+ Bar.all.to_json + '
         }
}'
  end
  
    def search
	print(params)
    @search = params[:search]
    render :text => '{
  "success":true,
  "info":"ok",
  "data":{
          "bars":'+  Bar.search(@search).to_json + '
         }
}'
  end
  
end