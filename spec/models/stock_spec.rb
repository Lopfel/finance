require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'associations' do
    it { should have_many(:portfolio_holdings) }
    it { should have_many(:portfolios).through(:portfolio_holdings) }

    it { should have_many(:portfolio_allocations) }
    it { should have_many(:allocated_portfolios).through(:portfolio_allocations).source(:portfolio) }
  end

  describe 'validations' do
    subject { build(:stock) }

    it { should validate_presence_of(:ticker) }
    it { should validate_uniqueness_of(:ticker) }
    it { should validate_presence_of(:name) }
  end

  describe '#fetch_current_price' do
    let(:stock) { create(:stock, ticker: 'AAPL', current_price: 140.0) }
    let(:memory_cache) { ActiveSupport::Cache::MemoryStore.new }

    before do
      allow(Rails).to receive(:cache).and_return(memory_cache)
      memory_cache.clear
    end

    context 'when FmpClient successfully returns a price' do
      it 'fetches the new price, updates the current_price in the database, and returns it' do
        expect(FmpClient).to receive(:fetch_quote).with('AAPL').and_return({ "price" => 155.5 })

        price = stock.fetch_current_price

        expect(price).to eq(155.5)
        expect(stock.reload.current_price).to eq(155.5)
      end

      it 'uses Rails cache so it does not query the API repeatedly within the expiration window' do
        expect(FmpClient).to receive(:fetch_quote).with('AAPL').once.and_return({ "price" => 150.0 })

        expect(stock.fetch_current_price).to eq(150.0)

        expect(stock.fetch_current_price).to eq(150.0)
      end
    end

    context 'when FmpClient returns nil' do
      it 'falls back to the existing current_price' do
        expect(FmpClient).to receive(:fetch_quote).with('AAPL').and_return(nil)

        price = stock.fetch_current_price

        expect(price).to eq(140.0)
      end
    end
  end
end
