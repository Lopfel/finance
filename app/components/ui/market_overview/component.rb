# frozen_string_literal: true

module Ui
  module MarketOverview
    class Component < ViewComponent::Base
      def initialize(portfolio:, stocks:, selected_stock:, chart_range:)
        @portfolio = portfolio
        @stocks = stocks
        @selected_stock = selected_stock
        @chart_range = chart_range
      end

      private

      attr_reader :portfolio, :stocks, :selected_stock, :chart_range

      def chart_url
        historical_prices_portfolio_path(
          portfolio,
          ticker: selected_stock.ticker,
          range: chart_range
        )
      end
    end
  end
end
