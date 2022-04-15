# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurScores do
  let(:subject) { Restitution::Illettrisme::InterpreteurScores.new scores_standardises }

  context 'pour des compétences de niveau 2' do
    let(:competences) { %i[score_ccf] }

    context 'sans score à interpreter' do
      let(:scores_standardises) { {} }

      it do
        expect(subject.interpretations(competences))
          .to eq([{ score_ccf: nil }])
      end
    end

    context 'au palier 0' do
      let(:scores_standardises) { { score_ccf: -1.41 } }

      it do
        expect(subject.interpretations(competences))
          .to eq([{ score_ccf: :palier0 }])
      end
    end

    context 'juste au dessus du palier 0' do
      let(:scores_standardises) { { score_ccf: -1.4 } }

      it do
        expect(subject.interpretations(competences))
          .to eq([{ score_ccf: :palier1 }])
      end
    end

    context 'juste en dessous du palier 2' do
      let(:scores_standardises) { { score_ccf: -0.26 } }

      it do
        expect(subject.interpretations(competences))
          .to eq([{ score_ccf: :palier1 }])
      end
    end

    context 'au palier 2' do
      let(:scores_standardises) { { score_ccf: -0.25 } }

      it do
        expect(subject.interpretations(competences))
          .to eq([{ score_ccf: :palier2 }])
      end
    end
  end

  context 'pour les compétences de niveau 1' do
    context 'sait interpreter les competences dans le référenciel CEFR' do
      let(:scores_standardises) { { litteratie: -3.55, numeratie: -1.64 } }

      it do
        expect(subject.interpretations(Restitution::ScoresNiveau1::METRIQUES_NIVEAU1,
                                       :CEFR))
          .to eq([{ litteratie: :palier0 }, { numeratie: :palier0 }])
      end
    end

    context 'sait interpreter les competences dans le référenciel ANLCI' do
      let(:scores_standardises) { { litteratie: -0.39, numeratie: 1.03 } }

      it do
        expect(subject.interpretations(Restitution::ScoresNiveau1::METRIQUES_NIVEAU1,
                                       :ANLCI))
          .to eq([{ litteratie: :palier5 }, { numeratie: :palier5 }])
      end
    end
  end
end
