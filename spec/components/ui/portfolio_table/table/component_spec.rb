require "rails_helper"

RSpec.describe Ui::PortfolioTable::Table::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  let(:headers) { [ "Asset", "Current Shares", "Price", "Action" ] }

  it "renders the table structure, headers, and block content" do
    render_inline(described_class.new(headers: headers)) do
      "<tr><td colspan='4'>Mocked Row Content</td></tr>".html_safe
    end

    headers.each do |header|
      expect(page).to have_selector("th", text: header)
    end

    expect(page).to have_selector("table.w-full tbody")

    expect(page).to have_text("Mocked Row Content")
  end
end
