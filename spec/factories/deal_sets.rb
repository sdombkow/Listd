# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deal_set do
    fecha_id 1
    total_released_deals 1
    sold_deals 1
    unsold_deals 1
    revenue_total "9.99"
    revenue_percentage "9.99"
  end
end
