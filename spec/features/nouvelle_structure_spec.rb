require 'rails_helper'

describe 'Nouvelle Structure', type: :feature do
  let!(:parcours_type_complet) { create :parcours_type, :complet }

  def extract_field_value(field)
    case field.tag_name
    when 'input'
      return nil if field[:type] == 'checkbox' && !field.checked?
      return nil if field[:type] == 'radio' && !field.checked?

      field[:value]
    when 'select'
      field.value
    when 'textarea'
      field.value
    end
  end

  def parse_field_name(field_name)
    field_name.match(/\A(\w+)(?:\[(\w+)\])?(?:\[(\w+)\])?\z/)
  end

  def set_nested_value(form_params, keys, value)
    current = form_params
    keys[0..-2].each do |key|
      current[key] ||= {}
      current = current[key]
    end
    current[keys.last] = value
  end

  def add_nested_param(form_params, field_name, value)
    name_parts = parse_field_name(field_name)
    return form_params[field_name] = value unless name_parts

    keys = [ name_parts[1], name_parts[2], name_parts[3] ].compact
    set_nested_value(form_params, keys, value)
  end

  def submit_nouvelle_structure_form
    form = find('#form-creation-structure')
    form_params = {}

    form.all('input, select, textarea', visible: :all).each do |field|
      next if field[:name].blank? || field[:type] == 'submit'

      value = extract_field_value(field)
      next if value.nil? || value.blank?

      add_nested_param(form_params, field[:name], value)
    end

    page.driver.submit :post, nouvelle_structure_path, form_params
  end

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
        submit_nouvelle_structure_form
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
      submit_nouvelle_structure_form
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
        submit_nouvelle_structure_form
      end.not_to change(StructureLocale, :count)

      message_erreur = I18n.t("activerecord.errors.models.structure.attributes.siret.blank")
      expect(page).to have_content(message_erreur)
      expect(page).to have_current_path(nouvelle_structure_path)
    end
  end

  context "quand le SIRET est invalide selon l'API SIRENE" do
    let(:mise_a_jour) { instance_double(MiseAJourSiret) }

    before do
      allow(MiseAJourSiret).to receive(:new).and_return(mise_a_jour)
      allow(mise_a_jour).to receive(:verifie_et_met_a_jour).and_return(false)

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
        submit_nouvelle_structure_form
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
        submit_nouvelle_structure_form
      end.to change(StructureLocale, :count)

      structure = Structure.order(:created_at).last
      expect(structure.statut_siret).to be true
      expect(structure.date_verification_siret).to be_present
    end
  end
end
