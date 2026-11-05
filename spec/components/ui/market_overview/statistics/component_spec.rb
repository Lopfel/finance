require "rails_helper"

RSpec.describe Ui::MarketOverview::Statistics::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  it "renders all statistics items with their labels, placeholders, and Stimulus targets" do
    render_inline(described_class.new)

    described_class::STATISTICS.each do |statistic|
      expect(page).to have_text(statistic[:label])
      expect(page).to have_selector("[data-candlestick-target='#{statistic[:target]}']", text: "--")
    end
  end
end
