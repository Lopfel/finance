require 'rails_helper'

RSpec.describe StockChartData do
  let(:stock) { create(:stock, ticker: "AAPL") }
  let(:memory_cache) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(Rails).to receive(:cache).and_return(memory_cache)
    memory_cache.clear
  end

  describe '#initialize' do
    it 'defaults to "3m" range if an invalid range is provided' do
      service = described_class.new(stock, range: "invalid_range")
      expect(service.instance_variable_get(:@range)).to eq("3m")
    end

    it 'accepts a valid range from PERIODS' do
      service = described_class.new(stock, range: "1y")
      expect(service.instance_variable_get(:@range)).to eq("1y")
    end
  end

  describe '#call' do
    let(:raw_prices_from_api) do
      [
        { "date" => "2026-01-02", "open" => 152.0, "high" => 155.0, "low" => 150.0, "close" => 154.0 },
        { "date" => "2026-01-01", "open" => 150.0, "high" => 153.0, "low" => 149.0, "close" => 151.0 },
        { "date" => "invalid_date", "open" => nil, "high" => 153.0, "low" => 149.0, "close" => 151.0 } # Este debe ser filtrado
      ]
    end

    it 'fetches historical prices from FmpClient using the correct limit, normalizes them, and calculates summary' do
      expect(FmpClient).to receive(:fetch_historical_prices)
        .with("AAPL", 63)
        .and_return(raw_prices_from_api)

      result = described_class.new(stock, range: "3m").call

      expect(result[:ticker]).to eq("AAPL")
      expect(result[:range]).to eq("3m")

      expect(result[:candles]).to eq([
        { time: "2026-01-01", open: 150.0, high: 153.0, low: 149.0, close: 151.0 },
        { time: "2026-01-02", open: 152.0, high: 155.0, low: 150.0, close: 154.0 }
      ])

      summary = result[:summary]
      expect(summary[:current_price]).to eq(154.0)
      expect(summary[:previous_price]).to eq(151.0)
      expect(summary[:change]).to eq(3.0)
      expect(summary[:positive]).to be(true)
      expect(summary[:highest]).to eq(155.0)
      expect(summary[:lowest]).to eq(149.0)
    end

    it 'uses Rails cache so FmpClient is not queried repeatedly' do
      expect(FmpClient).to receive(:fetch_historical_prices).once.and_return(raw_prices_from_api)

      service = described_class.new(stock, range: "1m")

      service.call

      service.call
    end

    context 'when candles are empty' do
      it 'returns empty candles and an empty summary hash' do
        expect(FmpClient).to receive(:fetch_historical_prices).and_return([])

        result = described_class.new(stock, range: "1m").call

        expect(result[:candles]).to eq([])
        expect(result[:summary]).to eq({})
      end
    end
  end
end
