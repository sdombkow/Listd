desc "This task is called by the Heroku scheduler add-on"
task :send_feedback => :environment do
  @pass_sets = PassSet.where("date = ?", Date.yesterday)
  @pass_sets.each do |pass_set|
	@passes = pass_set.passes
	@passes.each do |pass|
		@user=pass.purchase.user
		if(pass.redeemed?)
		UserMailer.send_feedback(@user).deliver
		else
		UserMailer.send_feedback(@user).deliver
		end
		puts "remove this line later"
	end
  end
end

task :update_bar_slug => :environment do
 Bar.find_each(&:save)
end