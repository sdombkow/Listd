# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :special do
    location_id 1
    name "MyString"
    price "9.99"
    available_start "2013-04-06"
    available_end "2013-04-06"
    description "MyText"
  end
end
