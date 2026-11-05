require 'rails_helper'

RSpec.describe Portfolios::DashboardData do
  let(:portfolio) { build(:portfolio).tap { |p| p.save(validate: false) } }
  let(:stock1) { create(:stock, current_price: 100.0, ticker: "AAPL") }
  let(:stock2) { create(:stock, current_price: 50.0, ticker: "MSFT") }

  let(:holdings_calculator_double) { instance_double(Portfolios::HoldingsCalculator) }
  let(:allocation_analyzer_double) { instance_double(Portfolios::AllocationAnalyzer) }

  let(:holdings_result) do
    {
      holdings_data: { "AAPL" => 500.0 },
      total_value: 500.0,
      positions_count: 1
    }
  end

  let(:allocation_result) do
    {
      rebalance_actions: [ { action: :buy } ],
      allocation_data: [],
      target_allocation_total: 100.0,
      rebalance_count: 1
    }
  end

  before do
    allow(Portfolios::HoldingsCalculator).to receive(:new).and_return(holdings_calculator_double)
    allow(holdings_calculator_double).to receive(:call).and_return(holdings_result)

    allow(Portfolios::AllocationAnalyzer).to receive(:new).with(portfolio).and_return(allocation_analyzer_double)
    allow(allocation_analyzer_double).to receive(:call).and_return(allocation_result)
  end

  describe '#call' do
    context 'when holdings and allocations are present' do
      let!(:holding) { create(:portfolio_holding, portfolio: portfolio, stock: stock1) }
      let!(:allocation) { create(:portfolio_allocation, portfolio: portfolio, stock: stock2) }

      it 'returns a complete dashboard hash containing metrics, stocks, and merged allocation data' do
        service = described_class.new(portfolio, ticker: "MSFT", range: "1y")
        result = service.call

        expect(result[:holdings]).to include(holding)
        expect(result[:allocations]).to include(allocation)
        expect(result[:holdings_data]).to eq(holdings_result[:holdings_data])
        expect(result[:total_value]).to eq(500.0)
        expect(result[:positions_count]).to eq(1)
        expect(result[:stocks]).to match_array([ stock1, stock2 ])
        expect(result[:selected_stock]).to eq(stock2)
        expect(result[:chart_range]).to eq("1y")
        expect(result[:rebalance_actions]).to eq([ { action: :buy } ])
        expect(result[:target_allocation_total]).to eq(100.0)
      end

      it 'defaults chart_range to "3m" when range parameter is blank or nil' do
        service = described_class.new(portfolio, range: nil)
        result = service.call

        expect(result[:chart_range]).to eq("3m")
      end

      it 'falls back to the first available stock if ticker parameter is not found' do
        service = described_class.new(portfolio, ticker: "UNKNOWN")
        result = service.call

        expect(result[:selected_stock]).to eq(stock1)
      end
    end
  end
end
