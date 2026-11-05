FactoryBot.define do
  factory :stock do
    sequence(:ticker) { |n| "STK#{n}" }
    sequence(:name) { |n| "Stock Name #{n}" }
    current_price { 150.0 }
  end
end
