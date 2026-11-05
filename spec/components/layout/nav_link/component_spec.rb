require "rails_helper"

RSpec.describe Layout::NavLink::Component, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  it "renders the nav link with inactive classes when not the current page" do
    helpers_double = double(current_page?: false)
    allow_any_instance_of(described_class).to receive(:helpers).and_return(helpers_double)

    render_inline(described_class.new(label: "Portfolios", path: "/portfolios"))

    expect(page).to have_link("Portfolios", href: "/portfolios")
    expect(page).to have_css("a.text-slate-400")
  end

  it "renders the nav link with active classes when it is the current page" do
    helpers_double = double(current_page?: true)
    allow_any_instance_of(described_class).to receive(:helpers).and_return(helpers_double)

    render_inline(described_class.new(label: "Portfolios", path: "/portfolios"))

    expect(page).to have_link("Portfolios", href: "/portfolios")
    expect(page).to have_css("a.text-white.bg-slate-700\\/70")
  end
end
