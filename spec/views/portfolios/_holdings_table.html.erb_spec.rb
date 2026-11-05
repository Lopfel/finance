require "rails_helper"

RSpec.describe "portfolios/_holdings_table", type: :view do
  include Rails.application.routes.url_helpers

  let(:portfolio) { build(:portfolio, id: 1).tap { |p| p.save(validate: false) } }

  before do
    assign(:portfolio, portfolio)
  end

  context "when @rebalance_actions are present" do
    let(:rebalance_actions) do
      {
        "AAPL" => {
          stock_name: "Apple Inc.",
          current_shares: 10,
          current_price: 150.0,
          current_value: 1500.0,
          current_percentage: 50.0,
          target_percentage: 50.0,
          action: :hold,
          shares_difference: 0,
          estimated_amount: 0
        }
      }
    end

    it "renders the titles, rebalance button, table headers, and rows" do
      assign(:rebalance_actions, rebalance_actions)

      render

      expect(rendered).to have_text(I18n.t("holding.title"))
      expect(rendered).to have_text(I18n.t("holding.subtitle"))

      expect(rendered).to have_button(I18n.t("holding.rebalance"))
      expect(rendered).to have_selector("form[action='#{rebalance_portfolio_path(portfolio)}'][method='post']")

      expect(rendered).to have_text(I18n.t("holding.stock"))
      expect(rendered).to have_text(I18n.t("holding.quantity"))
      expect(rendered).to have_text(I18n.t("holding.price"))

      expect(rendered).to have_text("AAPL")
      expect(rendered).to have_text("Apple Inc.")
    end
  end

  context "when @rebalance_actions are blank or empty" do
    it "renders the empty state message" do
      assign(:rebalance_actions, {})

      render

      expect(rendered).to have_text(I18n.t("holding.no_rebalance_recommendations"))
    end
  end
end
