require "rails_helper"

RSpec.describe "portfolios/show", type: :view do
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::NumberHelper

  let(:portfolio) { build(:portfolio, id: 1).tap { |p| p.save(validate: false) } }
  let(:stock) { create(:stock, ticker: "AAPL", name: "Apple Inc.") }

  before do
    assign(:portfolio, portfolio)
    assign(:total_value, 25000.75)
    assign(:positions_count, 4)
    assign(:rebalance_count, 2)
    assign(:stocks, [ stock ])
    assign(:selected_stock, stock)
    assign(:chart_range, "3m")
    assign(:allocation_data, [
      { ticker: "AAPL", stock_name: "Apple Inc.", current_percentage: 100.0, target_percentage: 100.0 }
    ])
    assign(:target_allocation_total, 100.0)
    assign(:rebalance_actions, {})
  end

  it "renders all stat cards, market overview, portfolio allocation, and holdings table correctly" do
    render

    expect(rendered).to have_text("NAV Total Portfolio Value")
    expect(rendered).to have_text("$25,000.75")

    expect(rendered).to have_text("Total Positions")
    expect(rendered).to have_text("4")

    expect(rendered).to have_text("Assets to Rebalance")
    expect(rendered).to have_text("2")

    expect(rendered).to have_text(I18n.t("market_overview.header.title"))
    expect(rendered).to have_text(I18n.t("portfolio_allocation.title"))
    expect(rendered).to have_text(I18n.t("holding.title"))
  end
end
