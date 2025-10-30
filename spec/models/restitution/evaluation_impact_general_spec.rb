require 'rails_helper'

describe Restitution::EvaluationImpactGeneral do
  describe '#synthese' do
    let(:evaluation_impact_general) { described_class.new(nil, nil) }
    let(:performance_collective_attendu) { :faible }
    let(:agilite_organisationnelle_attendu) { :moyen }
    let(:securite_qualite_attendu) { :fort }
    let(:mobilite_professionnelle_attendu) { :tres_fort }
    let(:score_cout_attendu) { 10 }
    let(:score_strategie_attendu) { 20 }
    let(:score_numerique_attendu) { 30 }

    before do
      allow(evaluation_impact_general).to receive_messages(
        calcule_performance_collective: performance_collective_attendu,
        calcule_agilite_organisationnelle: agilite_organisationnelle_attendu,
        calcule_securite_qualite: securite_qualite_attendu,
        calcule_mobilite_professionnelle: mobilite_professionnelle_attendu,
        calcule_score_cout: score_cout_attendu,
        calcule_score_strategie: score_strategie_attendu,
        calcule_score_numerique: score_numerique_attendu
      )
    end

    it 'calcule les interprétations de scoring' do
      synthese = evaluation_impact_general.synthese
      expect(synthese[:performance_collective]).to eq(performance_collective_attendu)
      expect(synthese[:agilite_organisationnelle]).to eq(agilite_organisationnelle_attendu)
      expect(synthese[:securite_qualite]).to eq(securite_qualite_attendu)
      expect(synthese[:mobilite_professionnelle]).to eq(mobilite_professionnelle_attendu)
    end

    it 'calcule les scores par impact' do
      synthese = evaluation_impact_general.synthese
      expect(synthese[:score_cout]).to eq(score_cout_attendu)
      expect(synthese[:score_strategie]).to eq(score_strategie_attendu)
      expect(synthese[:score_numerique]).to eq(score_numerique_attendu)
    end
  end
end
