require "rails_helper"

RSpec.describe Ui::StatCard::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  it "renders the stat card with title, value, and default color" do
    render_inline(described_class.new(
      title: "Total Portfolio Value",
      value: "$12,450.00"
    ))

    expect(page).to have_text("Total Portfolio Value")
    expect(page).to have_text("$12,450.00")
    expect(page).to have_selector("h3.text-sky-400")
  end

  it "renders optional icon, subtitle, and custom accent color" do
    render_inline(described_class.new(
      title: "Monthly Return",
      value: "+5.4%",
      icon: "📈",
      subtitle: "Compared to last month",
      color: "green"
    ))

    expect(page).to have_text("Monthly Return")
    expect(page).to have_text("+5.4%")
    expect(page).to have_text("📈")
    expect(page).to have_text("Compared to last month")

    expect(page).to have_selector("h3.text-emerald-400")
  end

  it "falls back to default blue color for unknown color parameters" do
    render_inline(described_class.new(
      title: "Active Positions",
      value: "8",
      color: "unknown_color"
    ))

    expect(page).to have_selector("h3.text-sky-400")
  end
end
