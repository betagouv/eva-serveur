# frozen_string_literal: true

require 'rails_helper'

describe 'Nouvelle Structure', type: :feature do
  let!(:parcours_type_complet) { create :parcours_type, :complet }

  context 'quand le formulaire est complété' do
    before do
      visit nouvelle_structure_path
      fill_in :compte_prenom, with: 'Jimmy'
      fill_in :compte_nom, with: 'Endriques'
      fill_in :compte_telephone, with: '02 03 04 05 06'
      fill_in :compte_email, with: 'jeanmarc@structure.fr'
      fill_in :compte_password, with: 'billyjoel'
      fill_in :compte_password_confirmation, with: 'billyjoel'
      fill_in :compte_structure_attributes_nom, with: 'Mission Locale Nice'
      select 'Mission locale'
      fill_in :compte_structure_attributes_code_postal, with: '06000'
    end

    it 'créé stucture et compte' do
      expect do
        click_on 'Valider la création de mon compte'
      end.to change(StructureLocale, :count)
        .and change(Compte, :count)

      compte = Compte.last
      expect(compte.email).to eq('jeanmarc@structure.fr')
      expect(compte.role).to eq('admin')
      expect(compte.telephone).to eq('02 03 04 05 06')

      structure = Structure.order(:created_at).last
      expect(structure.nom).to eq('Mission Locale Nice')
      expect(structure.type_structure).to eq('mission_locale')
      expect(structure.code_postal).to eq('06000')

      expect(compte.structure_id).to eq(structure.id)
      expect(compte.validation_acceptee?).to eq(true)

      expect(current_path).to eq(admin_dashboard_path)
      expect(page).to have_content 'Bienvenue ! Vous vous êtes bien enregistré(e).'
    end
  end

  context "quand le formulaire n'est pas complété" do
    before { visit nouvelle_structure_path }

    it 'ne remplie pas tous les champs' do
      click_on 'Valider la création de mon compte'
    end
  end
end
