FactoryBot.define do
  factory :portfolio_allocation do
    portfolio
    stock
    target_percentage { 100.0 }
  end
end
