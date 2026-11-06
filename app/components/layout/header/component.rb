# frozen_string_literal: true

module Layout
  module Header
    class Component < ViewComponent::Base
      def initialize(user:)
        @user = user
      end

      attr_reader :user

      def render?
        user.present?
      end

      def nav_items
        portfolio = user.portfolios.first

        return [] unless portfolio

        [
          [ t("header.portfolio"), helpers.portfolio_path(portfolio) ]
        ]
      end
    end
  end
end
