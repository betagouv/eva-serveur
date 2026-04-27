require 'rails_helper'

describe 'Admin - Actualités', type: :feature, js: true do
  let(:compte) { create :compte_superadmin }

  before do
    create(:actualite, titre: 'Une actualité de test')
    connecte(compte)
  end

  fit "ouvre le menu d'actions au clic sur le bouton menu" do
    visit admin_actualites_path

    expect(page).to have_css('.actualite .bouton-menu')
    expect(page).not_to have_css('.actualite .table_actions.montrer')

    find('.actualite .bouton-menu').click

    expect(page).to have_css('.actualite .table_actions.montrer')
  end
end
