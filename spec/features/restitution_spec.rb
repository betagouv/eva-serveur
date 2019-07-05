# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Restitution', type: :feature do
  let(:evaluation) { create :evaluation }

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

    visit admin_restitution_path(evenement)
    expect(page).to have_content('Pièces Bien Placées 1')
    expect(page).to have_content('Pièces Mal Placées 2')
    expect(page).to have_content('Pièces Non Triées 0')
  end

  scenario 'rapport de la situation inventaire' do
    situation_inventaire = create :situation_inventaire
    evenement = create :evenement_saisie_inventaire, :echec, session_id: 'session_inventaire',
                                                             situation: situation_inventaire,
                                                             evaluation: evaluation
    visit admin_restitution_path(evenement)
    expect(page).to have_content('Échec')
  end
end
