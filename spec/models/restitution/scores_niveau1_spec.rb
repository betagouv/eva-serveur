# frozen_string_literal: true

require 'rails_helper'

describe Restitution::ScoresNiveau1 do
  let(:scores_niveau2) { double }

  let(:scores_niveau1) do
    Restitution::ScoresNiveau1.new(scores_niveau2)
  end

  it 'à partir des score standardisés de niveau 2' do
    allow(scores_niveau2).to receive(:calcule)
      .and_return(score_numeratie: 1,
                  score_ccf: 2,
                  score_syntaxe_orthographe: 3,
                  score_memorisation: 4)
    expect(scores_niveau1.calcule)
      .to eq(
        litteratie: (2 + 3 + (4 * 0.25)) / 2.25,
        numeratie: 1
      )
  end

  it 'avec une metrique manquante' do
    allow(scores_niveau2).to receive(:calcule)
      .and_return(score_numeratie: 1,
                  score_ccf: nil,
                  score_syntaxe_orthographe: 3,
                  score_memorisation: 4)
    expect(scores_niveau1.calcule)
      .to eq(
        litteratie: (3 + (4 * 0.25)) / 1.25,
        numeratie: 1
      )
  end
end
