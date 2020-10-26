# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Globale do
  let(:situation)  { create :situation_objets_trouves }
  let(:evaluation) { create :evaluation }
  let(:evaluation2) { create :evaluation }
  let(:partie_moyenne) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           metriques: {
             score_ccf: 0.28,
             score_memorisation: 0.33
           }
  end
  let(:partie2) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           metriques: {
             score_ccf: 0
           }
  end

  let(:partie3) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           metriques: {
             score_ccf: 0.44
           }
  end

  let(:partie4) do
    create :partie,
           situation: situation,
           evaluation: evaluation2,
           metriques: {
             score_ccf: 0.44
           }
  end

  let(:partie_sans_metrique) do
    create :partie,
           situation: situation,
           evaluation: evaluation2,
           metriques: {}
  end

  let(:restitution_evaluation1) { FabriqueRestitution.restitution_globale(evaluation) }
  let(:restitution_evaluation2) { FabriqueRestitution.restitution_globale(evaluation2) }

  before do
    # pour que les restitutions puisse retrouver les parties !
    create(:evenement_demarrage, partie: partie_moyenne)
    create(:evenement_demarrage, partie: partie2)
    create(:evenement_demarrage, partie: partie3)
    create(:evenement_demarrage, partie: partie4)
    create(:evenement_demarrage, partie: partie_sans_metrique)
  end

  describe 'calcul des scores' do
    let(:score_ccf1) { (0.28 - 0.28) / 0.09 }
    let(:score_ccf2) { (0 - 0.28) / 0.09 }
    let(:score_ccf3) { (0.44 - 0.28) / 0.09 }

    let(:score_ccf_niveau_2) { -0.44 } # moyenne des 3 scores
    let(:score_memorisation_niveau_2) { 1.0 } # (0.33 - 0.22) / 0.11

    let(:score_ccf_niveau_2_standardise) { -0.99 } # (score_ccf_niveau_2 - 0.16) / 0.61
    let(:score_memorisation_niveau_2_standardise) { 0.83 } # (1 - 0.23) / 0.93

    context 'de niveau 2' do
      it do
        expect(restitution_evaluation1.scores_niveau2.calcule[:score_ccf].round(2))
          .to eql(score_ccf_niveau_2)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises.calcule[:score_ccf].round(2))
          .to eql(score_ccf_niveau_2_standardise)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises
          .calcule[:score_syntaxe_orthographe]).to eql(nil)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2
          .calcule[:score_memorisation].round(2)).to eql(score_memorisation_niveau_2)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises
          .calcule[:score_memorisation].round(2))
          .to eql(score_memorisation_niveau_2_standardise)
      end
    end

    context 'de niveau 1' do
      let(:score_litteratie) { -0.08 } # moyenne des scores standardisés niveau 2
      let(:score_litteratie_standardise) { -0.4 } # (-0.08 - 0.11) / 0.48

      it do
        expect(restitution_evaluation1.scores_niveau1.calcule[:litteratie].round(2))
          .to eql(score_litteratie)
      end

      it do
        expect(restitution_evaluation1.scores_niveau1.calcule[:numeratie])
          .to eql(nil)
      end

      it do
        expect(restitution_evaluation1.scores_niveau1_standardises.calcule[:litteratie].round(2))
          .to eql(score_litteratie_standardise)
      end
    end
  end
end
