# frozen_string_literal: true

require 'rails_helper'

describe 'Nouvelle Structure', type: :feature do
  before do
    visit nouvelle_structure_path
    fill_in :campagne_libelle, with: 'Nice, pack demandeur'
    fill_in :campagne_code, with: 'packdemandeur_nice'
    fill_in :campagne_compte_attributes_prenom, with: 'Jimmy'
    fill_in :campagne_compte_attributes_nom, with: 'Endriques'
    fill_in :campagne_compte_attributes_telephone, with: '02 03 04 05 06'
    fill_in :campagne_compte_attributes_email, with: 'jeanmarc@structure.fr'
    fill_in :campagne_compte_attributes_password, with: 'billyjoel'
    fill_in :campagne_compte_attributes_password_confirmation, with: 'billyjoel'
    fill_in :campagne_compte_attributes_structure_attributes_nom, with: 'Mission Locale Nice'
    fill_in :campagne_compte_attributes_structure_attributes_code_postal, with: '06000'
  end

  it 'créé stucture, compte et campagne' do
    expect do
      click_on 'Valider la création de mon compte'
    end.to change(Structure, :count)
      .and change(Compte, :count)
      .and change(Campagne, :count)
    campagne = Campagne.last
    expect(campagne.libelle).to eq('Nice, pack demandeur')
    expect(campagne.code).to eq('packdemandeur_nice')
    expect(campagne.affiche_competences_fortes).to eq(true)

    compte = Compte.last
    expect(compte.email).to eq('jeanmarc@structure.fr')
    expect(compte.role).to eq('organisation')
    expect(compte.telephone).to eq('02 03 04 05 06')

    structure = Structure.order(:created_at).last
    expect(structure.nom).to eq('Mission Locale Nice')
    expect(structure.code_postal).to eq('06000')

    expect(campagne.compte_id).to eq(compte.id)
    expect(compte.structure_id).to eq(structure.id)
    expect(compte.validation_acceptee?).to eq(true)

    expect(current_path).to eq(admin_dashboard_path)
    expect(page).to have_content 'Bienvenue ! Vous vous êtes bien enregistré(e).'
  end

  it 'initialiser la campagne avec les situations par défaut si elles existes' do
    bienvenue = create :situation_bienvenue
    maintenance = create :situation_maintenance
    objets_trouves = create :situation_objets_trouves

    expect do
      click_on 'Valider la création de mon compte'
    end.to change(Campagne, :count)

    campagne = Campagne.last
    situations = campagne.situations_configurations.collect(&:situation)
    expect(situations).to eq([bienvenue, maintenance, objets_trouves])
  end
end
