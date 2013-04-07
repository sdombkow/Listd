# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :photo do
    location_id 1
    file_name "MyString"
    description "MyText"
  end
end
