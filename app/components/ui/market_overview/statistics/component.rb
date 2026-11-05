# frozen_string_literal: true

module Ui
  module MarketOverview
    module Statistics
      class Component < ViewComponent::Base
        STATISTICS = [
          { label: "Period high", target: "high" },
          { label: "Period low", target: "low" },
          { label: "Previous close", target: "previous" }
        ].freeze
      end
    end
  end
end
