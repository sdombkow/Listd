# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    user_id 1
    name "MyString"
    phone_number 1
    street_address "MyString"
    intro_paragraph "MyText"
    latitude 1.5
    longtitude 1.5
    logo "MyString"
    website_url "MyString"
    facebook_url "MyString"
    twitter_url "MyString"
    full_address "MyString"
    city "MyString"
    zip_code "MyString"
    state "MyString"
    slug "MyString"
  end
end
