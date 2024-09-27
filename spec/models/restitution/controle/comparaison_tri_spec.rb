# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Controle::ComparaisonTri do
  let(:restitution) { double }
  let(:restitution_hors_4_premiers) { double }

  before do
    allow(restitution).to receive_messages(abandon?: false, evenements: [1, 2, 3, 4])
    allow(restitution).to receive(:enleve_premiers_evenements_pieces)
      .with(4).and_return(restitution_hors_4_premiers)
  end

  context 'sans abandon' do
    context "lorsqu'il n'y a pas d'erreurs ou de ratées" do
      it 'a le niveau 4' do
        expect(restitution_hors_4_premiers).to receive(:nombre_mal_placees).and_return(0)
        expect(
          described_class.new(restitution).niveau
        ).to eql(Competence::NIVEAU_4)
      end
    end

    context "lorsqu'il y a une pièce mal placée hors 4 premières" do
      it 'a le niveau 3' do
        expect(restitution_hors_4_premiers).to receive(:nombre_mal_placees).and_return(1)
        expect(
          described_class.new(restitution).niveau
        ).to eql(Competence::NIVEAU_3)
      end
    end

    context "lorsqu'il y a deux pièces mal placées hors 4 premières" do
      it 'a le niveau 2' do
        expect(restitution_hors_4_premiers).to receive(:nombre_mal_placees).and_return(2)
        expect(
          described_class.new(restitution).niveau
        ).to eql(Competence::NIVEAU_2)
      end
    end

    context "lorsqu'il y a trois pièces mal placéee hors 4 premières" do
      it 'a le niveau 1' do
        expect(restitution_hors_4_premiers).to receive(:nombre_mal_placees).and_return(3)
        expect(
          described_class.new(restitution).niveau
        ).to eql(Competence::NIVEAU_1)
      end
    end
  end

  context 'avec abandon' do
    it 'a le niveau indéfini' do
      expect(restitution).to receive(:abandon?).and_return(true)
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_INDETERMINE)
    end
  end
end
