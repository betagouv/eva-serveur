# frozen_string_literal: true

require 'rails_helper'

describe Restitution::CalculateurScoresEvaluation do
  describe '#calcul_cote_z_score' do
    let(:standardisateur_evaluations) { double }
    let(:calculateur_scores_evaluation) do
      Restitution::CalculateurScoresEvaluation.new([], {}, nil)
    end

    context 'pas de scores' do
      it do
        allow(calculateur_scores_evaluation).to receive(:scores).and_return({})
        expect(calculateur_scores_evaluation.cote_z_scores(standardisateur_evaluations)).to eq({})
      end
    end

    context 'une restitution avec un score' do
      it do
        allow(calculateur_scores_evaluation).to receive(:scores).and_return(score_ccf: 110)
        allow(standardisateur_evaluations).to receive(:standardise)
          .with(:score_ccf, 110).and_return(1.1)
        expect(calculateur_scores_evaluation.cote_z_scores(standardisateur_evaluations))
          .to eq(score_ccf: 1.1)
      end
    end
  end
end
