require 'rails_helper'

describe Restitution::DiagRisquesEntreprise do
  describe '#synthese' do
    let(:diag_risques_entreprise) { described_class.new(nil, nil) }
    let(:expected_risk_percentage) { 42 }

    before do
      allow(diag_risques_entreprise).to receive(:calcule_pourcentage_risque).
        and_return(expected_risk_percentage)
    end

    it 'calculates pourcentage_risque and returns it in the synthese hash' do
      expect(diag_risques_entreprise.synthese[:pourcentage_risque]).to eq(expected_risk_percentage)
    end
  end
end
