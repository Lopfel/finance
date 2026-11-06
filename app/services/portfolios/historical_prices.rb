module Portfolios
  class HistoricalPrices
    def initialize(portfolio, ticker:, range:)
      @portfolio = portfolio
      @ticker = ticker.to_s.upcase
      @range = range
    end

    def call
      stock = find_stock

      StockChartData.new(stock, range: @range).call
    end

    private

    def find_stock
      @portfolio.stocks.find_by(ticker: @ticker) ||
        @portfolio.target_stocks.find_by!(ticker: @ticker)
    end
  end
end
