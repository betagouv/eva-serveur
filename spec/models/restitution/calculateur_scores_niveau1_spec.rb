# frozen_string_literal: true

require 'rails_helper'

describe Restitution::CalculateurScoresNiveau1 do
  let(:scores_niveau2) { double }

  let(:calculateur_scores_niveau1) do
    Restitution::CalculateurScoresNiveau1.new(scores_niveau2)
  end

  describe '#scores_niveau1' do
    it 'à partir des score standardisés de niveau 2' do
      allow(scores_niveau2).to receive(:calcule)
        .and_return(score_numeratie: 1,
                    score_ccf: 2,
                    score_syntaxe_orthographe: 3,
                    score_memorisation: 4)
      expect(calculateur_scores_niveau1.scores_niveau1)
        .to eq(litteratie: (2 + 3 + 4) / 3.0, numeratie: 1)
    end

    it 'avec une metrique manquante' do
      allow(scores_niveau2).to receive(:calcule)
        .and_return(score_numeratie: 1,
                    score_ccf: nil,
                    score_syntaxe_orthographe: 3,
                    score_memorisation: 4)
      expect(calculateur_scores_niveau1.scores_niveau1)
        .to eq(litteratie: (3 + 4) / 2.0, numeratie: 1)
    end
  end
end
