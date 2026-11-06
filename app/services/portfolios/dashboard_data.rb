module Portfolios
  class DashboardData
    def initialize(portfolio, ticker: nil, range: nil)
      @portfolio = portfolio
      @ticker = ticker
      @range = range
    end

    def call
      holdings = @portfolio.portfolio_holdings.includes(:stock)
      allocations = @portfolio.portfolio_allocations.includes(:stock)

      holdings_result = HoldingsCalculator.new(holdings).call
      allocation_result = AllocationAnalyzer.new(@portfolio).call

      {
        holdings: holdings,
        allocations: allocations,
        holdings_data: holdings_result[:holdings_data],
        total_value: holdings_result[:total_value],
        positions_count: holdings_result[:positions_count],
        stocks: available_stocks(holdings, allocations),
        selected_stock: selected_stock(holdings, allocations),
        chart_range: @range.presence || "3m"
      }.merge(allocation_result)
    end

    private

    def available_stocks(holdings, allocations)
      (holdings.map(&:stock) + allocations.map(&:stock)).compact.uniq
    end

    def selected_stock(holdings, allocations)
      stocks = available_stocks(holdings, allocations)

      stocks.find { |stock| stock.ticker == @ticker } || stocks.first
    end
  end
end
