require 'rails_helper'

describe Restitution::EvaluationImpactGeneral do
  describe '#synthese' do
    let(:evaluation_impact_general) { described_class.new(nil, nil) }
    let(:performance_collective_attendu) { :faible }
    let(:agilite_organisationnelle_attendu) { :moyen }
    let(:securite_qualite_attendu) { :fort }
    let(:mobilite_professionnelle_attendu) { :tres_fort }

    before do
      allow(evaluation_impact_general).to receive_messages(
        calcule_performance_collective: performance_collective_attendu,
        calcule_agilite_organisationnelle: agilite_organisationnelle_attendu,
        calcule_securite_qualite: securite_qualite_attendu,
        calcule_mobilite_professionnelle: mobilite_professionnelle_attendu
      )
    end

    it 'calculates pourcentage_risque and returns it in the synthese hash' do
      synthese = evaluation_impact_general.synthese
      expect(synthese[:performance_collective]).to eq(performance_collective_attendu)
      expect(synthese[:agilite_organisationnelle]).to eq(agilite_organisationnelle_attendu)
      expect(synthese[:securite_qualite]).to eq(securite_qualite_attendu)
      expect(synthese[:mobilite_professionnelle]).to eq(mobilite_professionnelle_attendu)
    end
  end
end
