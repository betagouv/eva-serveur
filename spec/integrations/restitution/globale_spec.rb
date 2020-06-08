# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Globale, type: :integration do
  context "Calcule le score global d'une méta-compétence d'une restitution" do
    let(:livraison) { create :situation_livraison }

    let(:partie) { create :partie, situation: livraison }
    let(:partie2) { create :partie, situation: livraison }

    let(:restitution_livraison) { FabriqueRestitution.instancie partie.id }
    let(:restitution2_livraison) { FabriqueRestitution.instancie partie2.id }

    let(:bon_choix) { create :choix, :bon }
    let(:question_numeratie) do
      create :question_qcm, metacompetence: :numeratie, choix: [bon_choix]
    end

    let(:campagne) { Campagne.new }
    let(:evaluation) { create :evaluation, campagne: campagne }

    before do
      create(:evenement_demarrage, partie: partie, date: Time.local(2019, 10, 9, 10, 1, 20))
      create(:evenement_affichage_question_qcm,
             partie: partie,
             donnees: { question: question_numeratie.id },
             date: Time.local(2019, 10, 9, 10, 1, 21))
      create(:evenement_reponse,
             partie: partie,
             donnees: { question: question_numeratie.id, reponse: bon_choix.id },
             date: Time.local(2019, 10, 9, 10, 1, 22))
      restitution_livraison.persiste

      create(:evenement_demarrage, partie: partie2, date: Time.local(2019, 10, 9, 10, 1, 20))
      create(:evenement_affichage_question_qcm,
             partie: partie2,
             donnees: { question: question_numeratie.id },
             date: Time.local(2019, 10, 9, 10, 1, 21))
      create(:evenement_reponse,
             partie: partie2,
             donnees: { question: question_numeratie.id, reponse: bon_choix.id },
             date: Time.local(2019, 10, 9, 10, 1, 23))
      restitution2_livraison.persiste

      expect(restitution_livraison.partie.metriques['score_numeratie']).to eq(1)
      expect(restitution_livraison.partie.cote_z_metriques['score_numeratie']).to eq(1)
      expect(restitution2_livraison.partie.cote_z_metriques['score_numeratie']).to eq(-1)
    end

    it do
      restitution_globale =
        Restitution::Globale.new restitutions: [restitution_livraison, restitution2_livraison],
                                 evaluation: evaluation
      restitution_globale.persiste
      expect(restitution_globale.evaluation.metriques['score_numeratie']).to eq((1 + -1) / 2)
    end
  end
end
