# frozen_string_literal: true

require 'rails_helper'

describe Restitution::CalculateurScoresEvaluation do
  let(:calculateur_scores_evaluation) do
    Restitution::CalculateurScoresEvaluation.new([], {}, nil)
  end

  describe '#calcule_scores_niveau2_standardises' do
    let(:standardisateur_evaluations) { double }

    context 'pas de scores de niveau2' do
      it do
        allow(calculateur_scores_evaluation).to receive(:scores_niveau2).and_return({})

        expect(calculateur_scores_evaluation
          .scores_niveau2_standardises(standardisateur_evaluations))
          .to eq({})
      end
    end

    context 'une restitution avec un score de niveau 2' do
      it do
        allow(calculateur_scores_evaluation).to receive(:scores_niveau2).and_return(score_ccf: 110)
        allow(standardisateur_evaluations).to receive(:standardise)
          .with(:score_ccf, 110).and_return(1.1)

        expect(calculateur_scores_evaluation
          .scores_niveau2_standardises(standardisateur_evaluations))
          .to eq(score_ccf: 1.1)
      end
    end
  end

  describe '#calcul_scores_niveau1_metriques' do
    let(:standardisateur_evaluations) { double }
    let(:standardisateur_niveau2) { double }

    it 'à partir des score standardisés de niveau 2' do
      allow(calculateur_scores_evaluation).to receive(:scores_niveau2_standardises)
        .with(standardisateur_niveau2)
        .and_return(score_numeratie: 1,
                    score_ccf: 2,
                    score_syntaxe_orthographe: 3,
                    score_memorisation: 4)
      expect(calculateur_scores_evaluation.scores_niveau1(standardisateur_niveau2))
        .to eq(litteratie: (2 + 3 + 4) / 3.0, numeratie: 1)
    end

    it 'avec une metrique manquante' do
      allow(calculateur_scores_evaluation).to receive(:scores_niveau2_standardises)
        .with(standardisateur_niveau2)
        .and_return(score_numeratie: 1,
                    score_ccf: nil,
                    score_syntaxe_orthographe: 3,
                    score_memorisation: 4)
      expect(calculateur_scores_evaluation.scores_niveau1(standardisateur_niveau2))
        .to eq(litteratie: (3 + 4) / 2.0, numeratie: 1)
    end
  end
end
