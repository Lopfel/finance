module Portfolios
  class HoldingsCalculator
    def initialize(holdings)
      @holdings = holdings
    end

    def call
      holdings_data = calculate_holdings
      total_value = holdings_data.sum { |holding| holding[:current_value] }

      holdings_data.each do |holding|
        holding[:current_percentage] = percentage(
          holding[:current_value],
          total_value
        )
      end

      {
        holdings_data: holdings_data,
        total_value: total_value,
        positions_count: @holdings.count { |holding| holding.quantity.positive? }
      }
    end

    private

    def calculate_holdings
      @holdings.map do |holding|
        current_price = holding.stock.fetch_current_price || 0
        current_value = holding.quantity * current_price

        {
          stock: holding.stock,
          quantity: holding.quantity,
          current_price: current_price,
          current_value: current_value,
          current_percentage: 0
        }
      end
    end

    def percentage(value, total)
      return 0 unless total.positive?

      (value / total) * 100
    end
  end
end
