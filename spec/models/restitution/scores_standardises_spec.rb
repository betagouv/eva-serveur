# frozen_string_literal: true

require 'rails_helper'

describe Restitution::ScoresStandardises do
  let(:standardisateur) { double }
  let(:scores) { double }

  let(:scores_standardises) do
    described_class.new(scores)
  end

  context 'pas de scores' do
    it do
      allow(scores).to receive(:calcule).and_return({})

      expect(scores_standardises.calcule).to eq({})
    end
  end

  context 'une restitution avec un score' do
    it do
      allow(scores_standardises).to receive(:standardisateur)
        .and_return(standardisateur)
      allow(scores).to receive(:calcule).and_return(score_ccf: 110)
      allow(standardisateur).to receive(:standardise)
        .with(:score_ccf, 110).and_return(1.1)

      expect(scores_standardises.calcule).to eq(score_ccf: 1.1)
    end
  end
end
