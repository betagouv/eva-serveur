require 'rails_helper'

describe Restitution::Inventaire::Rapidite do
  let(:restitution) { double }

  def pour(secondes: nil)
    allow(restitution).to receive(:temps_total).and_return(secondes)
    described_class.new(restitution)
  end

  context 'en cas de réussite' do
    before { expect(restitution).to receive(:reussite?).and_return(true) }

    describe "pour la version originale de l'inventaire" do
      before { expect(restitution).to receive(:version?).and_return(false) }

      it { expect(pour(secondes: 0.minutes.to_i)).to evalue_a(Competence::NIVEAU_4) }
      it { expect(pour(secondes: 10.minutes.to_i)).to evalue_a(Competence::NIVEAU_4) }
      it { expect(pour(secondes: 10.minutes.to_i + 1)).to evalue_a(Competence::NIVEAU_3) }
      it { expect(pour(secondes: 15.minutes.to_i)).to evalue_a(Competence::NIVEAU_3) }
      it { expect(pour(secondes: 15.minutes.to_i + 1)).to evalue_a(Competence::NIVEAU_2) }
      it { expect(pour(secondes: 30.minutes.to_i)).to evalue_a(Competence::NIVEAU_2) }
      it { expect(pour(secondes: 30.minutes.to_i + 1)).to evalue_a(Competence::NIVEAU_1) }
    end

    describe 'pour la version 2' do
      before { expect(restitution).to receive(:version?).with('2').and_return(true) }

      it { expect(pour(secondes: 6.minutes.to_i)).to evalue_a(Competence::NIVEAU_4) }
      it { expect(pour(secondes: 6.minutes.to_i + 1)).to evalue_a(Competence::NIVEAU_3) }
      it { expect(pour(secondes: 9.minutes.to_i)).to evalue_a(Competence::NIVEAU_3) }
      it { expect(pour(secondes: 9.minutes.to_i + 1)).to evalue_a(Competence::NIVEAU_2) }
      it { expect(pour(secondes: 18.minutes.to_i)).to evalue_a(Competence::NIVEAU_2) }
      it { expect(pour(secondes: 18.minutes.to_i + 1)).to evalue_a(Competence::NIVEAU_1) }
    end
  end

  context 'en cas de non réussite' do
    it 'a le niveau indéterminé' do
      expect(restitution).to receive(:reussite?).and_return(false)
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_INDETERMINE)
    end
  end
end
