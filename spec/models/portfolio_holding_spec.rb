require 'rails_helper'

RSpec.describe PortfolioHolding, type: :model do
  let(:user) { create(:user) }
  let(:portfolio) {
    p = build(:portfolio, user: user)
    p.save(validate: false)
    p
  }
  let(:stock) { create(:stock) }

  describe 'associations' do
    it { should belong_to(:portfolio) }
    it { should belong_to(:stock) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }

    it 'validates uniqueness of stock_id scoped to portfolio_id' do
      holding1 = PortfolioHolding.new(portfolio: portfolio, stock: stock, quantity: 100)
      holding1.save(validate: false)

      duplicate_holding = PortfolioHolding.new(portfolio: portfolio, stock: stock, quantity: 0)

      expect(duplicate_holding).not_to be_valid
      expect(duplicate_holding.errors[:stock_id]).to include("has already been taken")
    end
  end

  describe '#current_value' do
    let(:stock) { build_stubbed(:stock, current_price: 150.0) }
    let(:portfolio_holding) { build_stubbed(:portfolio_holding, quantity: 10, stock: stock) }

    it 'calculates the correct total value based on quantity and stock price' do
      expect(portfolio_holding.current_value).to eq(1500.0)
    end
  end
end
