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

  describe 'rapport de la situation livraison' do
    let(:situation) { create :situation_livraison }
    let(:bon_choix) { create :choix, :bon }
    let(:question_numeratie) do
      create :question_qcm, nom_technique: 'agenda-entrainement', choix: [bon_choix]
    end
    let!(:evenements) do
      [
        create(:evenement_demarrage,
               partie: partie,
               date: Time.zone.local(2019, 10, 9, 10, 1, 20)),
        create(:evenement_affichage_question_qcm,
               partie: partie,
               donnees: { question: question_numeratie.id },
               date: Time.zone.local(2019, 10, 9, 10, 1, 21)),
        create(:evenement_reponse,
               partie: partie,
               donnees: { question: question_numeratie.id, reponse: bon_choix.id },
               date: Time.zone.local(2019, 10, 9, 10, 1, 22))
      ]
    end

    before { visit admin_restitution_path(partie) }

    it { expect(page).to have_content('Nombre De Bonnes Réponses Numératie') }
  end

  describe "suppression d'une partie" do
    let(:situation) { create :situation_inventaire }
    let!(:evenements) do
      [create(:evenement_saisie_inventaire, :echec, partie: partie)]
    end

    before { visit admin_restitution_path(partie) }

    it do
      within('#action_items_sidebar_section') { click_on 'Supprimer' }

      expect(partie.reload.deleted?).to be true
      expect(evenements.first.reload.deleted?).to be true
      within('#main_content') { expect(page).to have_content 'John Doe' }
    end
  end
end
