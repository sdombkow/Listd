# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    user_id 1
    name "MyString"
    phone_number 1
    address "MyString"
    intro_paragraph "MyText"
    date_of_event "2013-04-06"
    time_of_event "2013-04-06 22:14:40"
    latitude 1.5
    longtitude 1.5
    logo "MyString"
    website_url "MyString"
    facebook_url "MyString"
    twitter_url "MyString"
    street_address "MyString"
    city "MyString"
    zip_code 1
    state "MyString"
    slug "MyString"
  end
end
