require "rails_helper"

RSpec.describe Ui::PortfolioAllocation::Item::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers
  include ActionView::Helpers::NumberHelper

  let(:allocation_data) do
    {
      ticker: "AAPL",
      stock_name: "Apple Inc.",
      current_percentage: 45.5,
      target_percentage: 50.0
    }
  end

  it "renders stock ticker, name, and formatted allocation percentages correctly" do
    render_inline(described_class.new(allocation: allocation_data))

    expect(page).to have_text("AAPL")
    expect(page).to have_text("Apple Inc.")

    expect(page).to have_text(I18n.t("portfolio_allocation.current_allocation"))
    expect(page).to have_text(I18n.t("portfolio_allocation.target_allocation"))

    expect(page).to have_text("45.50%")
    expect(page).to have_text("50.00%")
  end
end
