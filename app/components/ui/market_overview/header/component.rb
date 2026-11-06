# frozen_string_literal: true

module Ui
  module MarketOverview
    module Header
      class Component < ViewComponent::Base
        def initialize(portfolio:, stocks:, selected_stock:)
          @portfolio = portfolio
          @stocks = stocks
          @selected_stock = selected_stock
        end

        private

        attr_reader :portfolio, :stocks, :selected_stock
      end
    end
  end
end
