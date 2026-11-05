# frozen_string_literal: true

module Ui
  module PortfolioAllocation
    module Item
      class Component < ViewComponent::Base
        attr_reader :allocation

        def initialize(allocation:)
          @allocation = allocation
        end

        def ticker
          allocation[:ticker]
        end

        def stock_name
          allocation[:stock_name]
        end

        def current_percentage
          allocation[:current_percentage].to_f
        end

        def target_percentage
          allocation[:target_percentage].to_f
        end
      end
    end
  end
end
