# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Restitution', type: :feature do
  let(:evaluation) { create :evaluation, nom: 'John Doe' }

  before { se_connecter_comme_administrateur }

  scenario 'rapport de la situation controle' do
    situation_controle = create :situation_controle

    evenement = create :evenement_piece_bien_placee, situation: situation_controle,
                                                     evaluation: evaluation,
                                                     session_id: 'session_controle'
    create :evenement_piece_mal_placee, situation: situation_controle,
                                        evaluation: evaluation,
                                        session_id: 'session_controle'
    create :evenement_piece_mal_placee, situation: situation_controle,
                                        evaluation: evaluation,
                                        session_id: 'session_controle'

    visit admin_restitution_path(evenement.session_id)
    expect(page).to have_content('Pièces Bien Placées 1')
    expect(page).to have_content('Pièces Mal Placées 2')
    expect(page).to have_content('Pièces Non Triées 0')
  end

  scenario 'rapport de la situation inventaire' do
    situation_inventaire = create :situation_inventaire
    evenement = create :evenement_saisie_inventaire, :echec, session_id: 'session_inventaire',
                                                             situation: situation_inventaire,
                                                             evaluation: evaluation
    visit admin_restitution_path(evenement.session_id)
    expect(page).to have_content('Échec')
  end

  describe "suppression d'un évenement" do
    let(:situation) { create :situation_inventaire }
    let(:evenement) do
      create :evenement_saisie_inventaire, :echec, evaluation: evaluation, situation: situation
    end

    before { visit admin_restitution_path(evenement.session_id) }
    it do
      expect do
        click_on 'Supprimer'
      end.to change { Evenement.count }.by(-1)
      within('#main_content') { expect(page).to have_content 'John Doe' }
    end
  end
end
