require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }

    it { should have_many(:portfolio_holdings).dependent(:destroy) }
    it { should have_many(:stocks).through(:portfolio_holdings) }

    it { should have_many(:portfolio_allocations).dependent(:destroy) }
    it { should have_many(:target_stocks).through(:portfolio_allocations).source(:stock) }

    it { should accept_nested_attributes_for(:portfolio_allocations).allow_destroy(true) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:stock1) { create(:stock) }
    let(:stock2) { create(:stock) }

    context 'when total allocation percentage equals 100%' do
      it 'is valid' do
        portfolio = build(:portfolio, user: user, portfolio_allocations: [
          build(:portfolio_allocation, target_percentage: 60, stock: stock1),
          build(:portfolio_allocation, target_percentage: 40, stock: stock2)
        ])

        expect(portfolio).to be_valid
      end
    end

    context 'when total allocation percentage does not equal 100%' do
      it 'is invalid and adds an error on base' do
        portfolio = build(:portfolio, user: user, portfolio_allocations: [
          build(:portfolio_allocation, target_percentage: 50, stock: stock1),
          build(:portfolio_allocation, target_percentage: 30, stock: stock2)
        ])

        expect(portfolio).not_to be_valid
        expect(portfolio.errors[:base]).to include("Total allocation must equal 100% (current: 80.0%)")
      end
    end
  end

  describe '#total_value' do
    let(:user) { create(:user) }
    let(:portfolio) { build(:portfolio, user: user).tap { |p| p.save(validate: false) } }
    let(:stock1) { create(:stock, current_price: 100.0) }
    let(:stock2) { create(:stock, current_price: 50.0) }

    before do
      create(:portfolio_holding, portfolio: portfolio, stock: stock1, quantity: 2)
      create(:portfolio_holding, portfolio: portfolio, stock: stock2, quantity: 5)
    end

    it 'calculates the sum of all holdings values' do
      expect(portfolio.total_value).to eq(450.0)
    end
  end
end
