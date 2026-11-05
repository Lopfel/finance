FactoryBot.define do
  factory :portfolio_holding do
    portfolio
    stock
    quantity { 100 }
  end
end
