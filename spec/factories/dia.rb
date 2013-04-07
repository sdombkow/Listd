# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dium do
    location_id 1
    selling_passes false
    selling_reservations false
    selling_tickets false
    selling_deals false
  end
end
