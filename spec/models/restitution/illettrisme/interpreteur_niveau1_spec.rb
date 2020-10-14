# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurNiveau1 do
  let(:score_litteratie) { -Float::INFINITY }
  let(:score_numeratie) { -Float::INFINITY }
  let(:scores_standardises) { { litteratie: score_litteratie, numeratie: score_numeratie } }
  let(:detecteur_illettrisme) { double(illettrisme_potentiel?: illettrisme_potentiel) }
  let(:restitutions) { double }
  let(:subject) do
    Restitution::Illettrisme::InterpreteurNiveau1.new scores_standardises, restitutions
  end

  before do
    allow(Restitution::Illettrisme::DetecteurIllettrisme)
      .to receive(:new)
      .with(restitutions)
      .and_return(detecteur_illettrisme)
  end

  describe '#interprete' do
    let(:illettrisme_potentiel) { false }

    context 'Socle Cléa Atteint' do
      let(:score_litteratie) { 0 }
      let(:score_numeratie) { 0 }
      it { expect(subject.socle_clea?).to eq(true) }
      it do
        expect(subject.interpretations)
          .to eq([{ litteratie: :palier3 }, { numeratie: :palier3 }])
      end
    end

    context 'Socle Cléa Atteint non atteint, litteratie insufisante' do
      let(:score_litteratie) { -0.1 }
      let(:score_numeratie) { 0 }
      it { expect(subject.socle_clea?).to eq(false) }
    end

    context 'Socle Cléa Atteint non atteint, numeratie insufisante' do
      let(:score_litteratie) { 0 }
      let(:score_numeratie) { -0.1 }
      it { expect(subject.socle_clea?).to eq(false) }
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

  describe '#synthese' do
    context "en cas d'illettrisme potentiel" do
      let(:illettrisme_potentiel) { true }

      it { expect(subject.synthese).to eq 'illettrisme_potentiel' }
    end

    context "socle clea en cours d'aquisition" do
      let(:illettrisme_potentiel) { false }

      before { allow(subject).to receive(:socle_clea?).and_return(true) }

      it { expect(subject.synthese).to eq 'socle_clea' }
    end

    context 'Besoins de formation en mathématiques' do
      let(:illettrisme_potentiel) { false }
      let(:score_numeratie) { -1 }
      let(:score_litteratie) { 0 }

      before { allow(subject).to receive(:socle_clea?).and_return(false) }

      it { expect(subject.synthese).to eq 'ni_ni' }
    end

    context 'Besoins de formation en français' do
      let(:illettrisme_potentiel) { false }
      let(:score_numeratie) { 0 }
      let(:score_litteratie) { -1 }

      before { allow(subject).to receive(:socle_clea?).and_return(false) }

      it { expect(subject.synthese).to eq 'ni_ni' }
    end

    context 'Besoins de formation en français et mathématiques' do
      let(:illettrisme_potentiel) { false }
      let(:score_numeratie) { -1 }
      let(:score_litteratie) { -1 }

      before { allow(subject).to receive(:socle_clea?).and_return(false) }

      it { expect(subject.synthese).to eq 'ni_ni' }
    end
  end
end
