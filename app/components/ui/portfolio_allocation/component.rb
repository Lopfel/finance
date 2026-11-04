# frozen_string_literal: true

module Ui
  module PortfolioAllocation
    class Component < ViewComponent::Base
      attr_reader :allocations, :target_total, :rebalance_count

      def initialize(allocations:, target_total:, rebalance_count:)
        @allocations = allocations
        @target_total = target_total
        @rebalance_count = rebalance_count
      end
    end
  end
end
