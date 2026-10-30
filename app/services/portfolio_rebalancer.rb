
class PortfolioRebalancer
  TOLERANCE = 0.0001

  def initialize(portfolio)
    @portfolio = portfolio
  end

  def call
    holdings = @portfolio.portfolio_holdings.includes(:stock).index_by(&:stock_id)
    allocations = @portfolio.portfolio_allocations.includes(:stock).index_by(&:stock_id)

    stock_ids = (holdings.keys + allocations.keys).uniq

    stocks = Stock.where(id: stock_ids).index_by(&:id)

    prices = stocks.transform_values do |stock|
      stock.fetch_current_price.to_d
    end

    total_value = holdings.sum do |stock_id, holding|
      holding.quantity.to_d * prices.fetch(stock_id, 0.to_d)
    end

    return {} if total_value.zero?

    stock_ids.each_with_object({}) do |stock_id, actions|
      stock = stocks[stock_id]
      next unless stock

      price = prices.fetch(stock_id, 0.to_d)
      next unless price.positive?

      holding = holdings[stock_id]
      allocation = allocations[stock_id]

      current_shares = holding&.quantity.to_d
      target_percentage = allocation&.target_percentage.to_d

      target_value = total_value * target_percentage / 100
      current_value = current_shares * price

      difference = target_value - current_value
      shares_difference = difference / price

      action = if shares_difference > TOLERANCE
                 :buy
      elsif shares_difference < -TOLERANCE
                 :sell
      else
                 :hold
      end

      actions[stock.ticker] = {
        stock_name: stock.name,
        current_shares: current_shares.round(4),
        target_shares: (target_value / price).round(4),
        shares_difference: shares_difference.abs.round(4),
        action: action,
        estimated_amount: difference.abs.round(2),
        current_price: price,
        current_value: current_value.round(2),
        target_value: target_value.round(2),
        target_percentage: target_percentage
      }
    end
  end
end
