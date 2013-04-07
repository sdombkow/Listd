# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :friend_purchase do
    pass_id 1
    deal_id 1
    ticket_id 1
    reservation_id 1
    name "MyString"
    email "MyString"
  end
end
