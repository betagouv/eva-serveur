require 'rails_helper'

describe Restitution::EvaluationImpactGeneral do
  describe '#synthese' do
    it do
      expect(described_class.new(nil, nil).synthese).to eq({})
    end
  end
end
