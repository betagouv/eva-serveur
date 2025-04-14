# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurScores do
  let(:subject) { described_class.new scores_standardises }

  context 'pour des compétences de niveau 2' do
    let(:competences) { %i[score_ccf score_memorisation] }

    context 'pas de score à interpreter' do
      let(:scores_standardises) { {} }

      it do
        expect(subject.interpretations(competences))
          .to eq([ { score_ccf: nil }, { score_memorisation: nil } ])
      end
    end

    context 'competence <= à -1' do
      let(:scores_standardises) { { score_ccf: -1, score_memorisation: -4 } }

      it do
        expect(subject.interpretations(competences))
          .to eq([ { score_ccf: :palier0 }, { score_memorisation: :palier0 } ])
      end
    end

    context '-1 < competence <= à 0' do
      let(:scores_standardises) { { score_ccf: -0.99, score_memorisation: 0 } }

      it do
        expect(subject.interpretations(competences))
          .to eq([ { score_ccf: :palier1 }, { score_memorisation: :palier1 } ])
      end
    end

    context 'competence > à 0' do
      let(:scores_standardises) { { score_ccf: 0.1 } }

      it do
        expect(subject.interpretations(competences))
          .to eq([ { score_ccf: :palier2 }, { score_memorisation: nil } ])
      end
    end
  end

  context 'pour les compétences de niveau 1' do
    context 'sait interpreter les competences dans le référenciel CEFR' do
      let(:scores_standardises) { { litteratie: -3.55, numeratie: -1.64 } }

      it do
        expect(subject.interpretations(Restitution::ScoresNiveau1::METRIQUES_NIVEAU1,
                                       :CEFR))
          .to eq([ { litteratie: :palier0 }, { numeratie: :palier0 } ])
      end
    end

    context 'sait interpreter les competences dans le référenciel ANLCI' do
      let(:scores_standardises) { { litteratie: -0.39, numeratie: 1.03 } }

      it do
        expect(subject.interpretations(Restitution::ScoresNiveau1::METRIQUES_NIVEAU1,
                                       :ANLCI))
          .to eq([ { litteratie: :palier5 }, { numeratie: :palier5 } ])
      end
    end
  end
end
