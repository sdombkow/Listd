class Api::V1::TasksController < ApplicationController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  # Just skip the authentication for now
  before_filter :authenticate_user!, :except => [:check_mobile_login]

  respond_to :json

  def index
  @user=current_user
    render :text => '{
  "success":true,
  "info":"ok",
  "data":{
		  "user":'+@user.to_json + '
          "bars":'+Bar.all.as_json(include: [:pass_sets]).to_json + '
			"passes":' + @user.passes.where("redeemed = ?", false).to_json + '
         }
}'
  end
  
    def search
    @search = params[:search]
    render :text => '{
  "success":true,
  "info":"ok",
  "data":{
          "bars":'+  Bar.search(@search).as_json(include: [:pass_sets]).to_json + '
         }
}'
  end
  
  def check_mobile_login
        token = params[:token]

        user = FbGraph::User.me(token)
        user = user.fetch

        logged = User.find_or_create(user)

        respond_to do |format|
            format.html # index.html.erb
            format.json { render :json => logged.authentication_token }
        end
    end

    def passset
    @id = params[:id]
    render :text => '{
  "success":true,
  "data":{
  "info":"ok",
          "PassSet":'+ PassSet.find(@id).to_json + '
         }
}'
  end
      def passes
    @user=current_user
	@passes=@user.passes.where("redeemed = ?", false)
    render :text => '{
  "success":true,
  "data":{
  "info":"ok",
"passes":' + @passes.to_json(:include => [ :pass_set => { :include =>[ :bar ]}])  + '
         }
}'
  end
  
      def purchase
    @id = params[:id]
	@bar_id=params[:bar_id]
	@user=current_user
	@num_passes=params[:num_passes]
	@purchaseCost=params[:purchaseCost]
	@purchaseName=params[:purchaseName]
	@chargeToken=params[:chargeToken]
	@pass_set=PassSet.find(@id)
	
	
	@purchase = Purchase.new(params[:purchase])
	@purchase.user_id = current_user.id
	@purchase.date = Date.today
	@purchase.name= @purchaseName
	@purchase.bar=Bar.find(@bar_id)
	@purchase.pass_set=PassSet.find(@id)
	@purchase.num_passes=@num_passes
	@purchase.price=@purchaseCost
	@purchase.stripe_charge_token=@chargeToken
    @purchase.save!


	    		      if @pass_set.selling_passes == true
	                @pass_set.sold_passes+=num_passes
	                @pass_set.unsold_passes-=num_passes
	            else
	                @pass_set.sold_passes+=1
	                @pass_set.unsold_passes-=1
	            end
	@pass_set.revenue_total = @purchaseCost + @pass_set.revenue_total
	@pass_set.save!
	
	
	pass = Pass.new
	pass.name = @purchaseName
	pass.purchase_id = @purchase.id
	pass.pass_set_id = @pass_set.id
	pass.redeemed = false
	pass.price = @purchaseCost
	pass.entries=@num_passes
	pass.confirmation=SecureRandom.hex(4)
	pass.save!
	UserMailer.purchase_confirmation(@user,pass).deliver
    render :text => '{
  "success":true,
  "data":{
  "info":"ok",
          "Pass":'+ pass.to_json + '
         }
}'
  end
  
end