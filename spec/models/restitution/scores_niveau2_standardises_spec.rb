# frozen_string_literal: true

require 'rails_helper'

describe Restitution::ScoresNiveau2Standardises do
  let(:standardisateur_niveau2) { double }
  let(:scores_niveau2) { double }

  let(:scores_niveau2_standardises) do
    Restitution::ScoresNiveau2Standardises.new(scores_niveau2)
  end

  context 'pas de scores de niveau2' do
    it do
      allow(scores_niveau2).to receive(:calcule).and_return({})

      expect(scores_niveau2_standardises.calcule).to eq({})
    end
  end

  context 'une restitution avec un score de niveau 2' do
    it do
      allow(scores_niveau2_standardises).to receive(:standardisateur_niveau2)
        .and_return(standardisateur_niveau2)
      allow(scores_niveau2).to receive(:calcule).and_return(score_ccf: 110)
      allow(standardisateur_niveau2).to receive(:standardise)
        .with(:score_ccf, 110).and_return(1.1)

      expect(scores_niveau2_standardises.calcule).to eq(score_ccf: 1.1)
    end
  end
end
