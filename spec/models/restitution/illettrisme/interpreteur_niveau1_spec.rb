# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurNiveau1 do
  describe '#interprete' do
    let(:score_litteratie) { -Float::INFINITY }
    let(:score_numeratie) { -Float::INFINITY }
    let(:scores_standardises) { { litteratie: score_litteratie, numeratie: score_numeratie } }
    let(:subject) { Restitution::Illettrisme::InterpreteurNiveau1.new scores_standardises }

    context 'Socle Cléa Atteint' do
      let(:score_litteratie) { 0 }
      let(:score_numeratie) { 0 }
      it { expect(subject.interpretations).to eq([{ socle_clea: :description }]) }
    end

    context 'litteratie < -1' do
      let(:score_litteratie) { -1.01 }
      it { expect(subject.interpretations).to include({ litteratie: :palier1 }) }
    end

    context '-1 <= litteratie < 0' do
      let(:score_litteratie) { -1 }
      it { expect(subject.interpretations).to include({ litteratie: :palier2 }) }
    end

    context 'litteratie >= 0' do
      let(:score_litteratie) { 0 }
      it { expect(subject.interpretations).to include({ litteratie: :palier3 }) }
    end

    context 'numeratie < -1' do
      let(:score_numeratie) { -1.01 }
      it { expect(subject.interpretations).to include({ numeratie: :palier1 }) }
    end

    context '-1 <= numeratie < 0' do
      let(:score_numeratie) { -1 }
      it { expect(subject.interpretations).to include({ numeratie: :palier2 }) }
    end

    context 'numeratie >= 0' do
      let(:score_numeratie) { 0 }
      it { expect(subject.interpretations).to include({ numeratie: :palier3 }) }
    end

    context 'pas de score' do
      let(:score_litteratie) { nil }
      let(:score_numeratie) { nil }
      it do
        expect(subject.interpretations)
          .to eq [{ litteratie: nil }, { numeratie: nil }]
      end
    end
  end
end
