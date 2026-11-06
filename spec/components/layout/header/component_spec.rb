require "rails_helper"

RSpec.describe Layout::Header::Component, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers
  include Capybara::RSpecMatchers

  let(:user) { create(:user, name: "Kinverly Felix") }

  context "when user is present" do
    it "renders the header with user information and navigation items" do
      portfolio = build(:portfolio, user: user).tap { |p| p.save(validate: false) }

      render_inline(described_class.new(user: user))

      expect(page).to have_text("KI")
      expect(page).to have_text("Kinverly Felix")
      expect(page).to have_link(I18n.t("header.portfolio"), href: portfolio_path(portfolio))
    end

    it "renders guest label if user name is blank" do
      user.update(name: nil)

      render_inline(described_class.new(user: user))

      expect(page).to have_text(I18n.t("header.guest"))
    end
  end

  context "when user is nil (render? condition)" do
    it "does not render the component" do
      result = render_inline(described_class.new(user: nil))

      expect(result.to_html).to be_blank
    end
  end
end
