# frozen_string_literal: true

require 'rails_helper'

describe "Admin - Demandes d'accompagnement", type: :feature do
  describe 'création' do
    let(:evaluation) { create :evaluation }
    let(:conseiller) { create :compte_conseiller, structure: create(:structure, :avec_admin) }
    before { connecte(conseiller) }

    it "fait une demande d'accompagnement" do
      visit new_admin_evaluation_demande_accompagnement_path(evaluation.id)

      fill_in :demande_accompagnement_conseiller_nom, with: 'Dupont'
      fill_in :demande_accompagnement_conseiller_prenom, with: 'Jean'
      fill_in :demande_accompagnement_conseiller_email, with: 'jean.dupont@example.com'
      fill_in :demande_accompagnement_conseiller_telephone, with: '0629101010'

      choose 'Je ne sais pas comment faire financer une formation'

      expect do
        click_on 'Envoyer'
      end.to change(DemandeAccompagnement, :count)

      demande_accompagnement = DemandeAccompagnement.last
      expect(demande_accompagnement.compte).to eq conseiller
      expect(demande_accompagnement.evaluation).to eq evaluation
    end

    context 'quand mon problème rencontré ne fait pas partie de ce listé' do
      it 'renseigne mon problème particulier que je rencontre' do
        visit new_admin_evaluation_demande_accompagnement_path(evaluation.id)

        fill_in :demande_accompagnement_conseiller_nom, with: 'Dupont'
        fill_in :demande_accompagnement_conseiller_prenom, with: 'Jean'
        fill_in :demande_accompagnement_conseiller_email, with: 'jean.dupont@example.com'
        fill_in :demande_accompagnement_conseiller_telephone, with: '0629101010'

        choose 'Autre'
        fill_in :demande_accompagnement_probleme_rencontre_custom, with: "J'ai un autre soucis !"

        click_on 'Envoyer'

        demande_accompagnement = DemandeAccompagnement.last
        expect(demande_accompagnement.probleme_rencontre).to eq "J'ai un autre soucis !"
      end
    end
  end
end
