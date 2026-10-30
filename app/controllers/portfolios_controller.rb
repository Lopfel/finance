
class PortfoliosController < ApplicationController
  before_action :set_portfolio

  def show
    @holdings = @portfolio.portfolio_holdings.includes(:stock)
    @allocations = @portfolio.portfolio_allocations.includes(:stock)

    @prices = {}

    stocks = (@holdings.map(&:stock) + @allocations.map(&:stock)).uniq

    stocks.each do |stock|
      @prices[stock.id] = stock.fetch_current_price
    end

    @total_value = @holdings.sum do |holding|
      holding.quantity * @prices.fetch(holding.stock_id, 0).to_d
    end

    @holdings_data = @holdings.map do |holding|
      stock = holding.stock
      price = @prices.fetch(stock.id, 0).to_d
      value = holding.quantity * price

      {
        stock: stock,
        quantity: holding.quantity,
        current_price: price,
        current_value: value,
        current_percentage: @total_value.positive? ? (value / @total_value * 100) : 0,
        target_percentage: @allocations.find {
          |allocation| allocation.stock_id == stock.id
        }&.target_percentage || 0
      }
    end

    @allocation_data = @allocations.map do |allocation|
      holding = @holdings.find {
        |item| item.stock_id == allocation.stock_id
      }

      value = holding ? holding.quantity * @prices.fetch(allocation.stock_id, 0).to_d : 0

      {
        stock: allocation.stock,
        target_percentage: allocation.target_percentage,
        current_percentage: @total_value.positive? ? value / @total_value * 100 : 0
      }
    end
  end

  def rebalance
    @rebalance_actions = PortfolioRebalancer.new(@portfolio).call

    respond_to do |format|
      format.html
      format.json { render json: @rebalance_actions }
    end
  end

  def historical_prices
    ticker = params[:ticker].to_s.upcase

    stock = @portfolio.stocks.find_by(ticker: ticker) ||
            @portfolio.target_stocks.find_by(ticker: ticker)

    return head :not_found unless stock

    prices = FmpClient.fetch_historical_prices(
      stock.ticker,
      params[:limit].presence || 90
    )

    render json: prices.reverse.map { |price|
      {
        time: price["date"],
        open: price["open"],
        high: price["high"],
        low: price["low"],
        close: price["close"]
      }
    }
  end

  private

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end
end
