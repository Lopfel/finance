require "rails_helper"

RSpec.describe Ui::PortfolioAllocation::ProgressBar::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  it "renders the progress bar with the specified color and width percentage" do
    render_inline(described_class.new(percentage: 65.5, color: "bg-blue-500"))

    expect(page).to have_css("div.bg-blue-500[style*='width: 65.5%']")
  end

  it "clamps percentages greater than 100 to 100" do
    render_inline(described_class.new(percentage: 150, color: "bg-green-500"))

    expect(page).to have_css("div[style*='width: 100%']")
  end

  it "clamps negative percentages to 0" do
    render_inline(described_class.new(percentage: -25, color: "bg-red-500"))

    expect(page).to have_css("div[style*='width: 0%']")
  end
end
