require 'rails_helper'

RSpec.describe Portfolios::PortfolioRebalancer do
  let(:user) { create(:user) }
  let(:portfolio) { build(:portfolio, user: user).tap { |p| p.save(validate: false) } }

  let(:stock_aapl) { create(:stock, ticker: "AAPL", name: "Apple Inc.", current_price: 150.0) }
  let(:stock_msft) { create(:stock, ticker: "MSFT", name: "Microsoft Corp.", current_price: 300.0) }

  subject(:rebalancer) { described_class.new(portfolio) }

  before do
    allow_any_instance_of(Stock).to receive(:fetch_current_price) do |stock|
      stock.current_price
    end
  end

  describe '#call' do
    context 'when total portfolio value is zero' do
      it 'returns an empty hash' do
        expect(rebalancer.call).to eq({})
      end
    end

    context 'when portfolio has holdings and target allocations' do
      before do
        create(:portfolio_holding, portfolio: portfolio, stock: stock_aapl, quantity: 2) # 2 * 150 = $300 (50%)
        create(:portfolio_allocation, portfolio: portfolio, stock: stock_aapl, target_percentage: 50.0)

        create(:portfolio_holding, portfolio: portfolio, stock: stock_msft, quantity: 1) # 1 * 300 = $300 (50%)
        create(:portfolio_allocation, portfolio: portfolio, stock: stock_msft, target_percentage: 50.0)
      end

      it 'calculates rebalance actions and details correctly' do
        result = rebalancer.call

        expect(result).to have_key("AAPL")
        expect(result).to have_key("MSFT")

        expect(result["AAPL"][:action]).to eq(:hold)
        expect(result["AAPL"][:current_percentage]).to eq(50.0)
        expect(result["AAPL"][:target_percentage]).to eq(50.0)

        expect(result["MSFT"][:action]).to eq(:hold)
        expect(result["MSFT"][:current_percentage]).to eq(50.0)
      end
    end

    context 'when a stock needs to be bought or sold' do
      before do
        create(:portfolio_holding, portfolio: portfolio, stock: stock_aapl, quantity: 2)
        create(:portfolio_holding, portfolio: portfolio, stock: stock_msft, quantity: 1)

        create(:portfolio_allocation, portfolio: portfolio, stock: stock_aapl, target_percentage: 80.0)

        create(:portfolio_allocation, portfolio: portfolio, stock: stock_msft, target_percentage: 20.0)
      end

      it 'correctly identifies :buy and :sell actions with estimated amounts' do
        result = rebalancer.call

        expect(result["AAPL"][:action]).to eq(:buy)
        expect(result["AAPL"][:estimated_amount]).to eq(180.0)

        expect(result["MSFT"][:action]).to eq(:sell)
        expect(result["MSFT"][:estimated_amount]).to eq(180.0)
      end
    end
  end
end
