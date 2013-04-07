# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location_hour do
    location_id 1
    day_of_week_open "MyString"
    day_of_week_close "MyText"
    opening_time "2013-04-06 21:41:22"
    closing_time "2013-04-06 21:41:22"
  end
end
