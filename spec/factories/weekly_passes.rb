# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :weekly_pass do
    week_pass_id 1
    purchase_id 1
    name "MyString"
    redeemed false
    entries 1
    confirmation "MyString"
    price "9.99"
    total_price "9.99"
  end
end
