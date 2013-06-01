class WeeklyPass < ActiveRecord::Base
  extend FriendlyId
  friendly_id :confirmation
  
  validates :confirmation, :uniqueness => true

  belongs_to :week_pass
  belongs_to :purchase
  has_many :pass_friends
end
