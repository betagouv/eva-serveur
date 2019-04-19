# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Evaluation', type: :feature do
  before { se_connecter_comme_administrateur }

  scenario 'rapport de la situation controle' do
    create :evenement_piece_bien_placee, situation: 'controle', session_id: 'session_controle'
    create :evenement_piece_mal_placee, situation: 'controle', session_id: 'session_controle'
    create :evenement_piece_mal_placee, situation: 'controle', session_id: 'session_controle'

    visit admin_evaluation_path('session_controle')
    expect(page).to have_content('Pièces Bien Placées 1')
    expect(page).to have_content('Pièces Mal Placées 2')
    expect(page).to have_content('Pièces Ratées 0')
  end

  scenario 'rapport de la situation inventaire' do
    create :evenement_saisie_inventaire, situation: 'inventaire', session_id: 'session_inventaire'
    visit admin_evaluation_path('session_inventaire')
    expect(page).to have_content('Échec')
  end
end
