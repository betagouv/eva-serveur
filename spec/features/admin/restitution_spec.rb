# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Restitution', type: :feature do
  let(:evaluation) { create :evaluation, nom: 'John Doe' }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }

  before { se_connecter_comme_superadmin }

  describe 'rapport de la situation controle' do
    let(:situation) { create :situation_controle }
    let!(:evenements) do
      [
        create(:evenement_piece_bien_placee, partie: partie),
        create(:evenement_piece_mal_placee, partie: partie),
        create(:evenement_piece_mal_placee, partie: partie)
      ]
    end

    before { visit admin_restitution_path(partie) }

    it do
      expect(page).to have_content('Pièces Bien Placées 1')
      expect(page).to have_content('Pièces Mal Placées 2')
      expect(page).to have_content('Pièces Non Triées 0')
    end
  end

  describe 'rapport de la situation inventaire' do
    let(:situation) { create :situation_inventaire }
    let!(:evenements) do
      [create(:evenement_saisie_inventaire, :echec, partie: partie)]
    end
    before { visit admin_restitution_path(partie) }
    it { expect(page).to have_content('Échec') }
  end

  describe "suppression d'une partie" do
    let(:situation) { create :situation_inventaire }
    let!(:evenements) do
      [create(:evenement_saisie_inventaire, :echec, partie: partie)]
    end

    before { visit admin_restitution_path(partie) }
    it do
      expect do
        within('#action_items_sidebar_section') { click_on 'Supprimer' }
      end.to change { Evenement.count }.by(-1)
                                       .and change { Partie.count }.by(-1)
      within('#main_content') { expect(page).to have_content 'John Doe' }
    end
  end
end
