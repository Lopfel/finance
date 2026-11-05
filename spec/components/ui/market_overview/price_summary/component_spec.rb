require "rails_helper"

RSpec.describe Ui::MarketOverview::PriceSummary::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  it "renders title, placeholders, and range buttons with correct active state" do
    render_inline(described_class.new(chart_range: "3m"))

    expect(page).to have_text(I18n.t("market_overview.price_summary.last_closing_price"))

    expect(page).to have_selector("[data-candlestick-target='price']", text: "--")
    expect(page).to have_selector("[data-candlestick-target='change']", text: "--")

    %w[1m 3m 6m 1y].each do |range|
      expect(page).to have_button(range.upcase)
    end

    expect(page).to have_selector("button[data-range='3m'][aria-pressed='true']")

    expect(page).to have_selector("button[data-range='1m'][aria-pressed='false']")
    expect(page).to have_selector("button[data-range='6m'][aria-pressed='false']")
    expect(page).to have_selector("button[data-range='1y'][aria-pressed='false']")
  end
end
