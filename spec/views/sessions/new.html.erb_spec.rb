require "rails_helper"

RSpec.describe "sessions/new", type: :view do
  include Rails.application.routes.url_helpers

  it "renders the login form with email, password fields, and submit button" do
    render

    expect(rendered).to have_text(I18n.t("sessions.title"))

    expect(rendered).to have_selector("form[action='#{login_path}'][method='post']")

    expect(rendered).to have_field(I18n.t("sessions.email"), type: "email")
    expect(rendered).to have_field(I18n.t("sessions.password"), type: "password")

    expect(rendered).to have_button(I18n.t("sessions.login"))
  end
end
