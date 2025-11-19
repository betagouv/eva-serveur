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
      fill_in :compte_structure_attributes_siret, with: '12345678901234'
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
      expect(structure.siret).to eq('12345678901234')

      expect(compte.structure_id).to eq(structure.id)
      expect(compte.validation_acceptee?).to be(true)

      expect(page).to have_current_path(admin_dashboard_path, ignore_query: true)
      expect(page).to have_content 'Bienvenue ! Vous vous êtes bien enregistré(e).'
    end
  end

  context "quand le formulaire n'est pas complété" do
    before { visit nouvelle_structure_path }

    it 'ne remplie pas tous les champs' do
      click_on 'Valider la création de mon compte'
    end
  end

  context "quand le siret n'est pas renseigné" do
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

    it 'affiche une erreur et ne crée pas la structure' do
      expect do
        click_on 'Valider la création de mon compte'
      end.not_to change(StructureLocale, :count)

      message_erreur = I18n.t("activerecord.errors.models.structure.attributes.siret.blank")
      expect(page).to have_content(message_erreur)
      expect(page).to have_current_path(nouvelle_structure_path)
    end
  end

  context "quand le SIRET est invalide selon l'API SIRENE" do
    let(:verificateur) { instance_double(VerificateurSiret) }

    before do
      allow(VerificateurSiret).to receive(:new).and_return(verificateur)
      allow(verificateur).to receive(:verifie_et_met_a_jour).and_return(false)

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
      fill_in :compte_structure_attributes_siret, with: '12345678901234'
    end

    it 'affiche une erreur et ne crée pas la structure' do
      expect do
        click_on 'Valider la création de mon compte'
      end.not_to change(StructureLocale, :count)

      message_erreur = I18n.t("activerecord.errors.models.structure.attributes.siret.invalid")
      expect(page).to have_content(message_erreur)
      expect(page).to have_current_path(nouvelle_structure_path)
    end
  end

  context "quand le SIRET est valide selon l'API SIRENE" do
    before do
      # Surcharge le mock global du client SIRENE pour ce test
      # Le mock global retourne true par défaut, donc on peut le laisser tel quel
      # ou s'assurer qu'il est bien configuré

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
      fill_in :compte_structure_attributes_siret, with: '12345678901234'
    end

    it 'créé la structure avec le statut SIRET vérifié' do
      expect do
        click_on 'Valider la création de mon compte'
      end.to change(StructureLocale, :count)

      structure = Structure.order(:created_at).last
      expect(structure.statut_siret).to be true
      expect(structure.date_verification_siret).to be_present
    end
  end
end
