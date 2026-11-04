# frozen_string_literal: true

module Ui
  module PortfolioTable
    module Row
      class Component < ViewComponent::Base
        attr_reader :ticker, :recommendation

        def initialize(ticker:, recommendation:)
          @ticker = ticker
          @recommendation = recommendation
        end

        def action_styles
          {
            buy: "bg-emerald-500/10 text-emerald-400 border-emerald-500/20",
            sell: "bg-rose-500/10 text-rose-400 border-rose-500/20",
            hold: "bg-slate-500/10 text-slate-400 border-slate-500/20"
          }
        end

        def action
          recommendation[:action].to_sym
        end
      end
    end
  end
end
