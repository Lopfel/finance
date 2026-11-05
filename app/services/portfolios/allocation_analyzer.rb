module Portfolios
  class AllocationAnalyzer
    def initialize(portfolio)
      @portfolio = portfolio
    end

    def call
      rebalance_actions = Portfolios::PortfolioRebalancer.new(@portfolio).call
      allocation_data = build_allocation_data(rebalance_actions)

      {
        rebalance_actions: rebalance_actions,
        allocation_data: allocation_data,
        target_allocation_total: allocation_data.sum do |allocation|
          allocation[:target_percentage].to_f
        end,
        rebalance_count: allocation_data.count do |allocation|
          allocation[:action] != :hold
        end
      }
    end

    private

    def build_allocation_data(rebalance_actions)
      rebalance_actions.map do |ticker, recommendation|
        {
          ticker: ticker,
          stock_name: recommendation[:stock_name],
          current_percentage: recommendation[:current_percentage],
          target_percentage: recommendation[:target_percentage],
          action: recommendation[:action]
        }
      end
    end
  end
end
