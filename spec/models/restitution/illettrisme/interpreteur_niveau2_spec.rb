# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurNiveau2 do
  let(:subject) { Restitution::Illettrisme::InterpreteurNiveau2.new scores_standardises }
  let(:paliers) do
    { score_ccf: %i[palier1 palier2 palier3],
      score_memorisation: %i[palier1 palier2 palier3] }
  end

  context 'pas de score à interpreter' do
    let(:scores_standardises) { {} }
    it do
      expect(subject.interpretations(paliers))
        .to eq([{ score_ccf: nil }, { score_memorisation: nil }])
    end
  end

  context 'competence < à -1' do
    let(:scores_standardises) { { score_ccf: -1.01 } }
    it do
      expect(subject.interpretations(paliers))
        .to eq([{ score_ccf: :palier1 }, { score_memorisation: nil }])
    end
  end

  context '-1 < competence < à 0' do
    let(:scores_standardises) { { score_ccf: -1, score_memorisation: -0.1 } }
    it do
      expect(subject.interpretations(paliers))
        .to eq([{ score_ccf: :palier2 }, { score_memorisation: :palier2 }])
    end
  end

  context 'competence >= à 0' do
    let(:scores_standardises) { { score_ccf: 0 } }
    it do
      expect(subject.interpretations(paliers))
        .to eq([{ score_ccf: :palier3 }, { score_memorisation: nil }])
    end
  end
end
