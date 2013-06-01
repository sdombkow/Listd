# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :week_pass do
    bar_id 1
    week_total_released 1
    week_total_sold 1
    week_total_unsold 1
    week_cost "9.99"
  end
end
