require 'rails_helper'

describe 'Admin - Parcours type', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'index' do
    before do
      create :parcours_type, libelle: 'Parcours type #1'
      create :parcours_type, libelle: 'Parcours type #2'
      visit admin_parcours_type_index_path
    end

    it do
      expect(page).to have_content 'Parcours type #1'
      expect(page).to have_content 'Parcours type #2'
    end
  end

  describe 'création' do
    before do
      visit new_admin_parcours_type_path
      fill_in :parcours_type_libelle, with: 'Parcours complet'
      fill_in :parcours_type_nom_technique, with: 'complet'
      fill_in :parcours_type_duree_moyenne, with: '1 heure'
      fill_in :parcours_type_description, with: 'Ma description'
    end

    it do
      expect { click_on 'Créer' }.to(change(ParcoursType, :count))
      expect(ParcoursType.last.description).to eq('Ma description')
    end
  end
end
