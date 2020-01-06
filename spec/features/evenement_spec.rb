# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Evenement', type: :feature do
  let(:chemin) { "#{Rails.root}/spec/support/evenement/donnees.json" }
  let(:donnees) { JSON.parse(File.read(chemin)) }
  let(:situation) { create :situation_inventaire, libelle: 'Inventaire' }
  let(:campagne) { create :campagne }
  let(:evaluation) { create :evaluation, campagne: campagne }
  let!(:partie) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           session_id: '1898098HJk8902'
  end

  let!(:evenement) do
    create :evenement, nom: 'ouvertureContenant',
                       donnees: donnees,
                       partie: partie
  end

  let(:autre_evaluation) { create :evaluation }
  let!(:autre_partie) do
    create :partie, session_id: 'autre', situation: situation, evaluation: autre_evaluation
  end
  let!(:evenement_hors_campagne) { create :evenement, nom: 'horsCampagne', session_id: 'autre' }

  before do
    se_connecter_comme_administrateur
    visit admin_campagne_evenements_path(campagne)
  end

  it 'Affiche les événements de la campagne' do
    expect(page).to have_content 'ouvertureContenant'
    expect(page).to have_content donnees['type']
    expect(page).to have_content '1898098HJk8902'
    expect(page).to_not have_content 'horsCampagne'
  end

  it "Empêche l'administrateur de créer/modifier un événement" do
    expect(page).to_not have_content 'Créer'
    expect(page).to_not have_content 'Modifier'
  end
end
