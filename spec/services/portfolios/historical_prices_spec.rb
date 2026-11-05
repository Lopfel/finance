require 'rails_helper'

RSpec.describe Portfolios::HistoricalPrices do
  let(:portfolio) { build(:portfolio).tap { |p| p.save(validate: false) } }
  let(:stock) { create(:stock, ticker: "AAPL") }
  let(:target_stock) { create(:stock, ticker: "MSFT") }

  let(:chart_data_double) { instance_double(StockChartData) }
  let(:mock_chart_result) { { "AAPL" => [ 150.0, 152.5, 155.0 ] } }

  describe '#call' do
    context 'when the stock is found in portfolio.stocks' do
      before do
        create(:portfolio_holding, portfolio: portfolio, stock: stock)

        allow(StockChartData).to receive(:new)
          .with(stock, range: "1m")
          .and_return(chart_data_double)

        allow(chart_data_double).to receive(:call).and_return(mock_chart_result)
      end

      it 'fetches chart data successfully and normalizes ticker to uppercase' do
        service = described_class.new(portfolio, ticker: "aapl", range: "1m")
        result = service.call

        expect(result).to eq(mock_chart_result)
      end
    end

    context 'when the stock is found in portfolio.target_stocks' do
      before do
        create(:portfolio_allocation, portfolio: portfolio, stock: target_stock)

        allow(StockChartData).to receive(:new)
          .with(target_stock, range: "3m")
          .and_return(chart_data_double)

        allow(chart_data_double).to receive(:call).and_return(mock_chart_result)
      end

      it 'fetches chart data from target stocks successfully' do
        service = described_class.new(portfolio, ticker: "MSFT", range: "3m")
        result = service.call

        expect(result).to eq(mock_chart_result)
      end
    end

    context 'when the stock cannot be found in stocks or target_stocks' do
      it 'raises ActiveRecord::RecordNotFound' do
        service = described_class.new(portfolio, ticker: "UNKNOWN", range: "1m")

        expect { service.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
