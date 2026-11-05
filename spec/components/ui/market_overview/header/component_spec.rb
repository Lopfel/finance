require "rails_helper"

RSpec.describe Ui::MarketOverview::Header::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers
  include Rails.application.routes.url_helpers

  let(:portfolio) { build(:portfolio).tap { |p| p.save(validate: false) } }
  let(:stock_aapl) { create(:stock, ticker: "AAPL", name: "Apple Inc.") }
  let(:stock_msft) { create(:stock, ticker: "MSFT", name: "Microsoft Corp.") }
  let(:stocks) { [ stock_aapl, stock_msft ] }

  it "renders header titles and stock selector form with selected stock" do
    render_inline(described_class.new(
      portfolio: portfolio,
      stocks: stocks,
      selected_stock: stock_msft
    ))

    expect(page).to have_text(I18n.t("market_overview.header.title"))
    expect(page).to have_text(I18n.t("market_overview.header.subtitle"))

    expect(page).to have_selector("form[action='#{portfolio_path(portfolio)}'][method='get']")

    expect(page).to have_select("ticker", options: [ "AAPL", "MSFT" ], selected: "MSFT")
  end
end
