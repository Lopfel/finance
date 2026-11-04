
class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio

  def show
    @holdings = @portfolio.portfolio_holdings.includes(:stock)
    @allocations = @portfolio.portfolio_allocations.includes(:stock)

    @holdings_data = @holdings.map do |holding|
      stock = holding.stock

      current_price = stock.fetch_current_price || 0

      current_value = holding.quantity * current_price

      {
        stock: stock,
        quantity: holding.quantity,
        current_price: current_price,
        current_value: current_value,
        current_percentage: 0
      }
    end

    @total_value = @holdings_data.sum do |holding|
      holding[:current_value]
    end

    @holdings_data.each do |holding|
      holding[:current_percentage] =
        if @total_value.positive?
          (holding[:current_value] / @total_value) * 100
        else
          0
        end
    end

    @stocks = (
      @holdings.map(&:stock) +
      @allocations.map(&:stock)
    ).compact.uniq

    @selected_stock = @stocks.find do |stock|
      stock.ticker == params[:ticker]
    end || @stocks.first

    @chart_range = params[:range].presence || "3m"


    @rebalance_actions = PortfolioRebalancer.new(@portfolio).call

    @allocation_data = @rebalance_actions.map do |ticker, recommendation|
      {
        ticker: ticker,
        stock_name: recommendation[:stock_name],
        current_percentage: recommendation[:current_percentage],
        target_percentage: recommendation[:target_percentage],
        action: recommendation[:action]
      }
    end

    @target_allocation_total = @allocation_data.sum do |allocation|
      allocation[:target_percentage].to_f
    end

    @rebalance_count = @allocation_data.count do |allocation|
      allocation[:action] != :hold
    end

    @positions_count = @holdings.count do |holding|
      holding.quantity.positive?
    end
  end

  def historical_prices
    ticker = params[:ticker].to_s.upcase

    stock = @portfolio.stocks.find_by(ticker: ticker) ||
            @portfolio.target_stocks.find_by(ticker: ticker)

    return head :not_found unless stock

    chart_data = StockChartData.new(
      stock,
      range: params[:range]
    ).call

    render json: chart_data
  end

  def rebalance
    @rebalance_actions = PortfolioRebalancer.new(@portfolio).call

    respond_to do |format|
      format.html do
        redirect_to portfolio_path(@portfolio),
                    notice: "Portfolio rebalancing analysis completed."
      end

      format.json do
        render json: @rebalance_actions
      end
    end
  end

  private

  def set_portfolio
    @portfolio = if params[:id].present?
      current_user.portfolios.find_by(id: params[:id])
    else
      current_user.portfolios.first
    end

    return if @portfolio

    redirect_to new_user_session_path,
                alert: "No tienes un portafolio disponible."
  end
end
