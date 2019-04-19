# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Evaluation', type: :feature do
  before { se_connecter_comme_administrateur }

  scenario 'rapport de la situation controle' do
    create :evenement_piece_bien_placee, situation: 'controle', session_id: 'ma_session'

    visit admin_evaluation_path('ma_session')
    expect(page).to have_content('Pièces bien placées : 1')
  end
end
