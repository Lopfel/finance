# frozen_string_literal: true

module Ui
  module PortfolioTable
    module Table
      class Component < ViewComponent::Base
        attr_reader :headers

        def initialize(headers:)
          @headers = headers
        end
      end
    end
  end
end
