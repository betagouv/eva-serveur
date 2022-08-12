# frozen_string_literal: true

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
    context 'de niveau 2' do
      it do
        expect(restitution_evaluation1.scores_niveau2.calcule[:score_ccf].round(2))
          .to be(-2.35)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises.calcule[:score_ccf].round(2))
          .to be(-1.13)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises
          .calcule[:score_syntaxe_orthographe]).to be_nil
      end

      it do
        expect(restitution_evaluation1.scores_niveau2
          .calcule[:score_memorisation].round(2)).to be(-0.26)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises
          .calcule[:score_memorisation].round(2))
          .to be(-0.26)
      end
    end

    context 'de niveau 1' do
      it do
        expect(restitution_evaluation1.scores_niveau1.calcule[:litteratie].round(2))
          .to be(-0.95)
      end

      it do
        expect(restitution_evaluation1.scores_niveau1.calcule[:numeratie])
          .to be_nil
      end

      it do
        expect(restitution_evaluation1.scores_niveau1_standardises.calcule[:litteratie]
                                                                  .round(2))
          .to be(-0.94)
      end
    end
  end
end
