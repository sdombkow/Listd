# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :price_point do
    pass_set_id 1
    reservation_set_id 1
    ticket_set_id 1
    reservation_set_id 1
    price "9.99"
    num_released 1
    num_sold 1
    num_unsold 1
    description "MyText"
  end
end
