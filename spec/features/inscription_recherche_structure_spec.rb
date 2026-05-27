require 'rails_helper'

describe 'Recherche de structure par SIRET', type: :feature do
  let!(:compte_pro_connect) do
    create(
      :compte_pro_connect,
      email: 'conseiller@example.fr',
      prenom: 'Jean',
      nom: 'Dupont',
      siret: nil,
      structure: nil,
      etape_inscription: 'recherche_structure'
    )
  end

  before do
    inscription_pro_connect(compte_pro_connect)
  end

  context "quand le compte n'a pas de SIRET" do
    before do
      # On visite directement la page car le compte est déjà en étape recherche_structure
      visit inscription_recherche_structure_path
    end

    it 'affiche le formulaire de recherche de structure par SIRET' do
      expect(page).to have_current_path(inscription_recherche_structure_path)
      expect(page).to have_content('Identification de la structure')
      expect(page).to have_field('siret')
    end

    it "permet de revenir à l'étape précédente" do
      click_on 'Précédent'

      expect(page).to have_current_path(inscription_informations_compte_path)
    end
  end
end
