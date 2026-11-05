require "rails_helper"

RSpec.describe Ui::PortfolioAllocation::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers
  include ActionView::Helpers::NumberHelper

  let(:allocations) do
    [
      { ticker: "AAPL", stock_name: "Apple Inc.", current_percentage: 40.0, target_percentage: 50.0 },
      { ticker: "MSFT", stock_name: "Microsoft Corp.", current_percentage: 60.0, target_percentage: 50.0 }
    ]
  end

  context "when allocations are present" do
    it "renders the title, asset count, legend, individual items, and summary totals correctly" do
      render_inline(described_class.new(
        allocations: allocations,
        target_total: 100.0,
        rebalance_count: 2
      ))

      expect(page).to have_text(I18n.t("portfolio_allocation.title"))
      expect(page).to have_text("2 #{I18n.t("portfolio_allocation.assets")}")
      expect(page).to have_text(I18n.t("portfolio_allocation.description"))

      expect(page).to have_text("AAPL")
      expect(page).to have_text("Apple Inc.")
      expect(page).to have_text("MSFT")
      expect(page).to have_text("Microsoft Corp.")

      expect(page).to have_text("100.00%")
      expect(page).to have_text("2")
    end
  end

  context "when allocations are empty" do
    it "renders the empty data message and zeroed summaries" do
      render_inline(described_class.new(
        allocations: [],
        target_total: 0.0,
        rebalance_count: 0
      ))

      expect(page).to have_text(I18n.t("portfolio_allocation.no_data"))

      expect(page).to have_text("0.00%")
      expect(page).to have_text("0")
    end
  end
end
