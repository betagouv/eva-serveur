# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Globale do
  let(:campagne) { create :campagne }
  let(:situation)  { create :situation_objets_trouves }
  let(:evaluation) { create :evaluation, campagne: campagne }
  let(:evaluation2) { create :evaluation, campagne: campagne }
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
    campagne.situations_configurations.create situation: situation

    # pour que les restitutions puisse retrouver les parties !
    create(:evenement_demarrage, partie: partie_moyenne)
    create(:evenement_demarrage, partie: partie2)
    create(:evenement_demarrage, partie: partie3)
    create(:evenement_demarrage, partie: partie4)
    create(:evenement_demarrage, partie: partie_sans_metrique)
  end

  describe 'calcul des scores' do
    context 'de niveau 2' do
      it do
        expect(restitution_evaluation1.scores_niveau2.calcule[:score_ccf].round(2))
          .to eql(-2.36)
      end

      it do
        expect(restitution_evaluation1.scores_niveau2_standardises.calcule[:score_ccf].round(2))
          .to eql(-4.13)
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
          .to eql(-0.53)
      end
    end

    context 'de niveau 1' do
      it do
        expect(restitution_evaluation1.scores_niveau1.calcule[:litteratie].round(2))
          .to eql(-3.41)
      end

      it do
        expect(restitution_evaluation1.scores_niveau1.calcule[:numeratie])
          .to be_nil
      end

      it do
        expect(restitution_evaluation1.scores_niveau1_standardises.calcule[:litteratie]
                                                                  .round(2))
          .to eql(-5.49)
      end
    end
  end
end
