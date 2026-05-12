require 'rails_helper'

describe 'Admin - Actualités', :js, type: :feature do
  let(:compte) { create :compte_superadmin }

  before do
    create(:actualite, titre: 'Une actualité de test')
    connecte(compte)
  end

  it "ouvre le menu d'actions au clic sur le bouton menu" do
    visit admin_actualites_path
    page.find(".actualite", text: "Une actualité de test")

    expect(page).to have_css(".actualite", text: "Une actualité de test")
    within(".actualite", text: "Une actualité de test") do
      expect(page).to have_css(".bouton-menu", visible: :all)
      expect(page).not_to have_css(".table_actions.montrer", visible: :all)

      find(".bouton-menu", visible: :all).click
      sleep 0.25

      expect(page).to have_css(".table_actions.montrer", visible: :all)
    end
  end
end
