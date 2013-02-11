class AddChargeTokenToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :stripe_charge_token, :string
  end
end
