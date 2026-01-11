require "system_helper"

RSpec.describe "Home Page", type: :system do
  let(:home_page) { prism.library.home }

  scenario "visitor sees the landing page" do
    home_page.load

    expect(page).to have_content("Bet on Yourself")
    expect(page).to have_content("Strivo")
  end

  scenario "visitor can navigate to sign in" do
    home_page.load

    expect(home_page).to have_navbar
  end
end
