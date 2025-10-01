require 'rails_helper'

describe Restitution::Globale do
  let(:campagne) { create :campagne }
  let(:situation)  { create :situation_objets_trouves }
  let(:evaluation) { create :evaluation, campagne: campagne }
  let(:partie_moyenne) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           metriques: {
             score_ccf: 0.28,
             score_memorisation: 0.33
           }
  end

  let(:restitution_evaluation1) { FabriqueRestitution.restitution_globale(evaluation) }

  before do
    campagne.situations_configurations.create situation: situation

    create(:evenement_demarrage, partie: partie_moyenne)
  end

  describe 'calcul des scores' do
    let(:score_ccf1) { 0.0 } # (0.28 - 0.28) / 0.09 }
    let(:score_ccf2) { (0 - 0.28) / 0.09 }
    let(:score_ccf3) { (0.44 - 0.28) / 0.09 }

    let(:score_memorisation_niveau2) { 1.0 } # (0.33 - 0.22) / 0.11

    let(:score_ccf_niveau_2_standardise) { -0.26 } # (score_ccf1 - 0.16) / 0.61
    let(:score_memorisation_niveau_2_standardise) { 0.83 } # (1 - 0.23) / 0.93

    context 'de niveau 2' do
      it do
        expect(restitution_evaluation1.scores_niveau2.calcule[:score_ccf].round(2))
          .to eql(score_ccf1)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises.calcule[:score_ccf].round(2))
          .to eql(score_ccf_niveau_2_standardise)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises
          .calcule[:score_syntaxe_orthographe]).to be_nil
      end

      it do
        expect(restitution_evaluation1.scores_niveau2
          .calcule[:score_memorisation].round(2)).to eql(score_memorisation_niveau2)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises
          .calcule[:score_memorisation].round(2))
          .to eql(score_memorisation_niveau_2_standardise)
      end
    end

    context 'de niveau 1' do
      let(:score_litteratie) { 0.28 }
      let(:score_litteratie_standardise) { 0.19 } # (score_litteratie - 0.16) / 0.65

      it do
        expect(restitution_evaluation1.scores_niveau1.calcule[:litteratie].round(2))
          .to eql(score_litteratie)
      end

      it do
        expect(restitution_evaluation1.scores_niveau1.calcule[:numeratie])
          .to be_nil
      end

      it do
        expect(restitution_evaluation1.scores_niveau1_standardises.calcule[:litteratie]
                                                                  .round(2))
          .to eql(score_litteratie_standardise)
      end
    end
  end
end
