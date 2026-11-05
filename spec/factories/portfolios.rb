FactoryBot.define do
  factory :portfolio do
    user
    name { "Tech Portfolio" }

    trait :with_valid_allocations do
      after(:build) do |portfolio|
        portfolio.portfolio_allocations << build(:portfolio_allocation, target_percentage: 100.0, portfolio: portfolio)
      end
    end
  end
end
