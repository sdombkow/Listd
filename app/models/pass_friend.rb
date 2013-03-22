class PassFriend < ActiveRecord::Base
  attr_accessible :name, :pass_id, :email

  belongs_to :pass
end
