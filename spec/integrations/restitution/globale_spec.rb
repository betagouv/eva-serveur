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
             score_memorisation: 0.22
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

  context "calcule la moyenne des scores pour l'ensemble des évaluations" do
    it "quand il n'y a aucune valeur" do
      expect(restitution_evaluation1.scores_niveau2.calcule[:score_numeratie]).to eql(nil)
      expect(restitution_evaluation1.niveau2_moyennes_glissantes[:score_numeratie]).to eql(nil)
    end

    it "quand il n'y a qu'une seule valeur (qui est pile sur la moyenne)" do
      expect(restitution_evaluation1.scores_niveau2.calcule[:score_memorisation]).to eql(0.0)
      expect(restitution_evaluation1.niveau2_moyennes_glissantes[:score_memorisation].round(2))
        .to eql(0.0)
    end

    it 'quand il y a plusieurs valeurs' do
      expect(restitution_evaluation1.scores_niveau2.calcule[:score_ccf].round(2)).to eql(-0.44)
      expect(restitution_evaluation2.scores_niveau2.calcule[:score_ccf].round(2)).to eql(1.78)
      expect(restitution_evaluation1.niveau2_moyennes_glissantes[:score_ccf].round(2))
        .to eql(((-0.44 + 1.78) / 2).round(2))
    end
  end

  context 'calcule les scores de niveau 1 et leur moyenne' do
    it do
      expect(restitution_evaluation1.scores_niveau1.calcule[:litteratie].round(2))
        .to eql(-0.5)
      expect(restitution_evaluation1.scores_niveau1.calcule[:numeratie])
        .to eql(nil)
      expect(restitution_evaluation1.niveau1_moyennes_glissantes[:litteratie])
        .to eql(0.25)
      expect(restitution_evaluation1.niveau1_moyennes_glissantes[:numeratie]).to eql(0.0)
    end
  end
end
