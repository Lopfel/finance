# frozen_string_literal: true

module Ui
  module MarketOverview
    module PriceSummary
      class Component < ViewComponent::Base
        RANGES = %w[1m 3m 6m 1y].freeze

        def initialize(chart_range:)
          @chart_range = chart_range
        end

        private

        attr_reader :chart_range
      end
    end
  end
end
