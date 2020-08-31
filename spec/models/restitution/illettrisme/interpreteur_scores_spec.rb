# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurScores do
  let(:subject) { Restitution::Illettrisme::InterpreteurScores.new scores_standardises }
  let(:competences) { %i[score_ccf score_memorisation] }

  context 'pas de score à interpreter' do
    let(:scores_standardises) { {} }
    it do
      expect(subject.interpretations(competences))
        .to eq([{ score_ccf: nil }, { score_memorisation: nil }])
    end
  end

  context 'competence < à -1' do
    let(:scores_standardises) { { score_ccf: -1.01 } }
    it do
      expect(subject.interpretations(competences))
        .to eq([{ score_ccf: :palier1 }, { score_memorisation: nil }])
    end
  end

  context '-1 < competence < à 0' do
    let(:scores_standardises) { { score_ccf: -1, score_memorisation: -0.1 } }
    it do
      expect(subject.interpretations(competences))
        .to eq([{ score_ccf: :palier2 }, { score_memorisation: :palier2 }])
    end
  end

  context 'competence >= à 0' do
    let(:scores_standardises) { { score_ccf: 0 } }
    it do
      expect(subject.interpretations(competences))
        .to eq([{ score_ccf: :palier3 }, { score_memorisation: nil }])
    end
  end
end
