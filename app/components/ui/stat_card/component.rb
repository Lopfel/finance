module Ui
  module StatCard
    class Component < ViewComponent::Base
      def initialize(title:, value:, icon: nil, color: "blue", subtitle: nil)
        @title = title
        @value = value
        @icon = icon
        @color = color
        @subtitle = subtitle
      end

      def accent_class
        {
          "blue" => "text-sky-400",
          "green" => "text-emerald-400",
          "purple" => "text-violet-400",
          "red" => "text-rose-400",
          "cyan" => "text-cyan-400"
        }.fetch(@color, "text-sky-400")
      end
    end
  end
end
