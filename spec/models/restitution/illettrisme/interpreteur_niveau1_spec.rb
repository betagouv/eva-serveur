# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurNiveau1 do
  let(:interpreteur_score) { double }
  let(:subject) do
    Restitution::Illettrisme::InterpreteurNiveau1.new interpreteur_score
  end

  describe '#interpretations' do
    let(:interpretations) { [{ litteratie: :palier1 }, { numeratie: :palier1 }] }

    before do
      allow(interpreteur_score).to receive(:interpretations)
        .with(Restitution::ScoresNiveau1::METRIQUES_NIVEAU1)
        .and_return(interpretations)
    end

    it { expect(subject.interpretations).to eq(interpretations) }
  end

  describe '#interprete' do
    context 'Socle Cléa Atteint' do
      before do
        allow(interpreteur_score).to receive(:interpretations)
          .and_return([{ litteratie: :palier5 }, { numeratie: :palier5 }])
      end
      it { expect(subject.socle_clea?).to eq(true) }
    end

    context 'Socle Cléa Atteint non atteint, litteratie insufisante' do
      before do
        allow(interpreteur_score).to receive(:interpretations)
          .and_return([{ litteratie: :palier2 }, { numeratie: :palier3 }])
      end
      it { expect(subject.socle_clea?).to eq(false) }
    end

    context 'Socle Cléa Atteint non atteint, numeratie insufisante' do
      before do
        allow(interpreteur_score).to receive(:interpretations)
          .and_return([{ litteratie: :palier3 }, { numeratie: :palier2 }])
      end
      it { expect(subject.socle_clea?).to eq(false) }
    end

    context 'Illettrisme potentiel à cause de la litteratie' do
      before do
        allow(interpreteur_score).to receive(:interpretations)
          .and_return([{ litteratie: :palier0 }, { numeratie: :palier1 }])
      end
      it { expect(subject.illettrisme_potentiel?).to eq(true) }
    end

    context 'Illettrisme potentiel à cause de la numératie' do
      before do
        allow(interpreteur_score).to receive(:interpretations)
          .and_return([{ litteratie: :palier1 }, { numeratie: :palier0 }])
      end
      it { expect(subject.illettrisme_potentiel?).to eq(true) }
    end
  end

  describe '#synthese' do
    context "en cas d'illettrisme potentiel" do
      before { allow(subject).to receive(:illettrisme_potentiel?).and_return(true) }

      it { expect(subject.synthese).to eq 'illettrisme_potentiel' }
    end

    context "socle clea en cours d'aquisition" do
      before do
        allow(subject).to receive(:illettrisme_potentiel?).and_return(false)
        allow(subject).to receive(:socle_clea?).and_return(true)
      end

      it { expect(subject.synthese).to eq 'socle_clea' }
    end

    context 'intermédiaire' do
      before do
        allow(subject).to receive(:illettrisme_potentiel?).and_return(false)
        allow(subject).to receive(:socle_clea?).and_return(false)
      end

      it { expect(subject.synthese).to eq 'ni_ni' }
    end
  end
end
