require "rails_helper"

RSpec.describe Ui::MarketOverview::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers
  include Rails.application.routes.url_helpers

  let(:portfolio) { build(:portfolio).tap { |p| p.save(validate: false) } }
  let(:stock) { create(:stock, ticker: "AAPL", name: "Apple Inc.") }

  context "when selected_stock is present" do
    it "renders the market overview with subcomponents and correct Stimulus controller configuration" do
      render_inline(described_class.new(
        portfolio: portfolio,
        stocks: [ stock ],
        selected_stock: stock,
        chart_range: "3m"
      ))

      expected_url = historical_prices_portfolio_path(portfolio, ticker: "AAPL", range: "3m")
      expect(page).to have_selector("[data-controller='candlestick'][data-candlestick-url-value='#{expected_url}']")

      expect(page).to have_selector("[data-candlestick-target='chart']")
      expect(page).to have_selector("[data-candlestick-target='message']")
    end
  end

  context "when selected_stock is blank or nil" do
    it "renders the empty state message" do
      render_inline(described_class.new(
        portfolio: portfolio,
        stocks: [],
        selected_stock: nil,
        chart_range: "3m"
      ))

      expect(page).to have_text(I18n.t("market_overview.empty"))
      expect(page).to have_text(I18n.t("market_overview.empty_description"))
    end
  end
end
