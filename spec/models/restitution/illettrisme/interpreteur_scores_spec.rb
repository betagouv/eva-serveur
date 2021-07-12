# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurScores do
  let(:subject) { Restitution::Illettrisme::InterpreteurScores.new scores_standardises }
  let(:competences) { %i[score_ccf score_memorisation] }
  let(:competences_niveau1) { %i[litteratie_cefr numeratie_cefr litteratie_anlci numeratie_anlci] }

  context 'pas de score à interpreter' do
    let(:scores_standardises) { {} }
    it do
      expect(subject.interpretations(competences))
        .to eq([{ score_ccf: nil }, { score_memorisation: nil }])
    end
  end

  context 'competence <= à -1' do
    let(:scores_standardises) { { score_ccf: -1, score_memorisation: -4 } }
    it do
      expect(subject.interpretations(competences))
        .to eq([{ score_ccf: :palier0 }, { score_memorisation: :palier0 }])
    end
  end

  context '-1 < competence <= à 0' do
    let(:scores_standardises) { { score_ccf: -0.99, score_memorisation: 0 } }
    it do
      expect(subject.interpretations(competences))
        .to eq([{ score_ccf: :palier1 }, { score_memorisation: :palier1 }])
    end
  end

  context 'competence > à 0' do
    let(:scores_standardises) { { score_ccf: 0.1 } }
    it do
      expect(subject.interpretations(competences))
        .to eq([{ score_ccf: :palier2 }, { score_memorisation: nil }])
    end
  end

  context 'premiers paliers de literatie et numeratie' do
    let(:scores_standardises) do
      {
        litteratie_cefr: -4.1, numeratie_cefr: -1.68,
        litteratie_anlci: -4.1, numeratie_anlci: -1.68
      }
    end
    it do
      expect(subject.interpretations(competences_niveau1))
        .to eq([
                 { litteratie_cefr: :palier0 }, { numeratie_cefr: :palier0 },
                 { litteratie_anlci: :palier0 }, { numeratie_anlci: :palier0 }
               ])
    end
  end

  context 'juste au dessus des premiers paliers de litteratie et numeratie' do
    let(:scores_standardises) do
      {
        litteratie_cefr: -3.54, numeratie_cefr: -1.63,
        litteratie_anlci: -4.09, numeratie_anlci: -1.67
      }
    end
    it do
      expect(subject.interpretations(competences_niveau1))
        .to eq([
                 { litteratie_cefr: :palier1 }, { numeratie_cefr: :palier1 },
                 { litteratie_anlci: :palier1 }, { numeratie_anlci: :palier1 }
               ])
    end
  end
end
