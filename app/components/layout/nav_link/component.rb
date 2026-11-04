# frozen_string_literal: true

module Layout
  module NavLink
    class Component < ViewComponent::Base
      def initialize(label:, path:)
        @label = label
        @path = path
      end

      def active?
        helpers.current_page?(@path)
      end

      def classes
        base = "relative px-4 py-2.5 rounded-lg text-sm font-medium transition-all duration-200"

        active = "text-white bg-slate-700/70"
        inactive = "text-slate-400 hover:text-white hover:bg-slate-800"

        "#{base} #{active? ? active : inactive}"
      end
    end
  end
end
