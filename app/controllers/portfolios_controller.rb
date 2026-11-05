class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio

  def show
    dashboard = Portfolios::DashboardData.new(
      @portfolio,
      ticker: params[:ticker],
      range: params[:range]
    ).call

    @holdings = dashboard[:holdings]
    @allocations = dashboard[:allocations]
    @holdings_data = dashboard[:holdings_data]
    @total_value = dashboard[:total_value]
    @positions_count = dashboard[:positions_count]

    @stocks = dashboard[:stocks]
    @selected_stock = dashboard[:selected_stock]
    @chart_range = dashboard[:chart_range]

    @rebalance_actions = dashboard[:rebalance_actions]
    @allocation_data = dashboard[:allocation_data]
    @target_allocation_total = dashboard[:target_allocation_total]
    @rebalance_count = dashboard[:rebalance_count]
  end

  def historical_prices
    chart_data = Portfolios::HistoricalPrices.new(
      @portfolio,
      ticker: params[:ticker],
      range: params[:range]
    ).call

    render json: chart_data
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def rebalance
    @rebalance_actions = Portfolios::AllocationAnalyzer.new(
      @portfolio
    ).call[:rebalance_actions]

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

    redirect_to login_path,
                alert: "You are not authorized to access this portfolio."
  end
end
