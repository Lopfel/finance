require "rails_helper"

RSpec.describe Ui::PortfolioTable::Row::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers
  include ActionView::Helpers::NumberHelper

  let(:base_recommendation) do
    {
      stock_name: "Apple Inc.",
      current_shares: 10.5,
      current_price: 175.50,
      current_value: 1842.75,
      current_percentage: 45.0,
      target_percentage: 50.0,
      shares_difference: 2.5,
      estimated_amount: 438.75
    }
  end

  context "when action is :buy" do
    let(:recommendation) { base_recommendation.merge(action: :buy) }

    it "renders ticker, stock name, shares, currency values, percentages, and buy action badge with details" do
      render_inline(described_class.new(ticker: "AAPL", recommendation: recommendation)) do
      end

      expect(page).to have_text("AAPL")
      expect(page).to have_text("Apple Inc.")
      expect(page).to have_text("10.5")
      expect(page).to have_text("$175.50")
      expect(page).to have_text("$1,842.75")
      expect(page).to have_text("45.00%")
      expect(page).to have_text("50.00%")

      expect(page).to have_selector("span", text: "BUY")
      expect(page).to have_selector("span.bg-emerald-500\\/10.text-emerald-400")

      expect(page).to have_text("+2.5 shares")
      expect(page).to have_text("$438.75")
    end
  end

  context "when action is :sell" do
    let(:recommendation) { base_recommendation.merge(action: :sell) }

    it "renders sell action badge with negative difference details" do
      render_inline(described_class.new(ticker: "MSFT", recommendation: recommendation))

      expect(page).to have_text("MSFT")
      expect(page).to have_selector("span", text: "SELL")
      expect(page).to have_selector("span.bg-rose-500\\/10.text-rose-400")

      expect(page).to have_text("-2.5 shares")
    end
  end

  context "when action is :hold" do
    let(:recommendation) { base_recommendation.merge(action: :hold) }

    it "renders hold action badge and omits shares difference / estimated amount details" do
      render_inline(described_class.new(ticker: "GOOGL", recommendation: recommendation))

      expect(page).to have_text("GOOGL")
      expect(page).to have_selector("span", text: "HOLD")
      expect(page).to have_selector("span.bg-slate-500\\/10.text-slate-400")

      expect(page).not_to have_text("shares")
    end
  end
end
