# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :menu_item do
    location_id 1
    name "MyString"
    price "9.99"
    description "MyText"
  end
end
