require 'rails_helper'

describe Restitution::Controle::AttentionConcentration do
  let(:restitution) { double }

  context 'sans abandon' do
    before { allow(restitution).to receive(:abandon?).and_return(false) }

    context "lorsqu'il n'y a pas de loupées" do
      it 'a le niveau 4' do
        expect(restitution).to receive(:nombre_loupees).and_return(0)
        expect(
          described_class.new(restitution).niveau
        ).to eql(Competence::NIVEAU_4)
      end
    end

    context "lorsqu'il y a un loupée" do
      it 'a le niveau 3' do
        expect(restitution).to receive(:nombre_loupees).and_return(1)

        expect(
          described_class.new(restitution).niveau
        ).to eql(Competence::NIVEAU_3)
      end
    end

    context "lorsqu'il y a deux pièces loupées" do
      it 'a le niveau 2' do
        expect(restitution).to receive(:nombre_loupees).and_return(2)
        expect(
          described_class.new(restitution).niveau
        ).to eql(Competence::NIVEAU_2)
      end
    end

    context "lorsqu'il y a trois pièces loupées" do
      it 'a le niveau 1' do
        expect(restitution).to receive(:nombre_loupees).and_return(3)
        expect(
          described_class.new(restitution).niveau
        ).to eql(Competence::NIVEAU_1)
      end
    end

    context "lorsqu'il y a quatre pièces loupées" do
      it 'a le niveau 1' do
        expect(restitution).to receive(:nombre_loupees).and_return(4)
        expect(
          described_class.new(restitution).niveau
        ).to eql(Competence::NIVEAU_1)
      end
    end
  end

  context 'avec abandon' do
    it 'a un niveau indeterminé' do
      expect(restitution).to receive(:abandon?).and_return(true)
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_INDETERMINE)
    end
  end
end
