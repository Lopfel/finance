require 'rails_helper'

RSpec.describe Portfolios::AllocationAnalyzer do
  let(:portfolio) do
    p = build(:portfolio)
    p.portfolio_allocations.build(stock: create(:stock), target_percentage: 100.0)
    p.save!
    p
  end

  subject(:analyzer) { described_class.new(portfolio) }

  let(:rebalancer_double) { instance_double(Portfolios::PortfolioRebalancer) }

  let(:mock_rebalance_actions) do
    {
      "AAPL" => {
        stock_name: "Apple Inc.",
        current_percentage: 50.0,
        target_percentage: 40.0,
        action: :sell
      },
      "MSFT" => {
        stock_name: "Microsoft Corp.",
        current_percentage: 30.0,
        target_percentage: 60.0,
        action: :buy
      },
      "GOOGL" => {
        stock_name: "Alphabet Inc.",
        current_percentage: 20.0,
        target_percentage: 20.0,
        action: :hold
      }
    }
  end

  before do
    allow(Portfolios::PortfolioRebalancer).to receive(:new).with(portfolio).and_return(rebalancer_double)
    allow(rebalancer_double).to receive(:call).and_return(mock_rebalance_actions)
  end

  describe '#call' do
    it 'returns a structured hash with rebalance actions, allocation data, totals, and rebalance counts' do
      result = analyzer.call

      expect(result[:rebalance_actions]).to eq(mock_rebalance_actions)

      expect(result[:allocation_data]).to eq([
        {
          ticker: "AAPL",
          stock_name: "Apple Inc.",
          current_percentage: 50.0,
          target_percentage: 40.0,
          action: :sell
        },
        {
          ticker: "MSFT",
          stock_name: "Microsoft Corp.",
          current_percentage: 30.0,
          target_percentage: 60.0,
          action: :buy
        },
        {
          ticker: "GOOGL",
          stock_name: "Alphabet Inc.",
          current_percentage: 20.0,
          target_percentage: 20.0,
          action: :hold
        }
      ])

      expect(result[:target_allocation_total]).to eq(120.0)

      expect(result[:rebalance_count]).to eq(2)
    end
  end
end
