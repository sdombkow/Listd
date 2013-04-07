# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deal do
    deal_set_id 1
    purchase_id 1
    name "MyString"
    redeemed false
    entries 1
    price "9.99"
    confirmation "MyString"
  end
end
