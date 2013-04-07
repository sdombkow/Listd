# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :available_time, :class => 'AvailableTimes' do
    reservation_set_id 1
    reservation_time "2013-04-07 11:16:07"
    tables_available 1
    tables_sold 1
    tables_unsold 1
  end
end
