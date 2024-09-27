# frozen_string_literal: true

require 'rails_helper'

describe Restitution::ScoresNiveau1 do
  let(:scores_niveau2) { double }

  let(:scores_niveau1) do
    described_class.new(scores_niveau2)
  end

  it 'à partir des score standardisés de niveau 2' do
    allow(scores_niveau2).to receive(:calcule)
      .and_return(score_numeratie: 1,
                  score_ccf: 2,
                  score_syntaxe_orthographe: 3,
                  score_memorisation: 4)
    expect(scores_niveau1.calcule)
      .to eq(
        litteratie: (2 + 3 + 4) / 3.0,
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
        litteratie: (3 + 4) / 2.0,
        numeratie: 1
      )
  end

  it 'avec toutes les metriques manquantes' do
    allow(scores_niveau2).to receive(:calcule)
      .and_return(score_numeratie: nil,
                  score_ccf: nil,
                  score_syntaxe_orthographe: nil,
                  score_memorisation: nil)
    expect(scores_niveau1.calcule)
      .to eq(
        litteratie: nil,
        numeratie: nil
      )
  end
end
