class AddDeviseColumnsToUser < ActiveRecord::Migration
  def self.change
    change_table :users do |t|
       t.string :authentication_token
    end
  end

end
