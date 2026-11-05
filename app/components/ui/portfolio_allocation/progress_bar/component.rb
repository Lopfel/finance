# frozen_string_literal: true

module Ui
  module PortfolioAllocation
    module ProgressBar
      class Component < ViewComponent::Base
        def initialize(percentage:, color:)
          @percentage = percentage.to_f.clamp(0, 100)
          @color = color
        end

        attr_reader :percentage, :color
      end
    end
  end
end
