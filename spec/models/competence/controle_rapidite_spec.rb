# frozen_string_literal: true

require 'rails_helper'

describe Competence::ControleRapidite do
  let(:evaluation) { double }

  context "lorsqu'il n'y a pas de ratées" do
    it 'a le niveau 4' do
      expect(evaluation).to receive(:nombre_ratees).and_return(0)
      expect(
        described_class.new(evaluation).niveau
      ).to eql(Competence::NIVEAU_4)
    end
  end

  context "lorsqu'il y a une pièce ratée" do
    it 'a le niveau 3' do
      expect(evaluation).to receive(:nombre_ratees).and_return(1)
      expect(
        described_class.new(evaluation).niveau
      ).to eql(Competence::NIVEAU_3)
    end
  end

  context "lorsqu'il y a deux pièces ratées" do
    it 'a le niveau 2' do
      expect(evaluation).to receive(:nombre_ratees).and_return(2)
      expect(
        described_class.new(evaluation).niveau
      ).to eql(Competence::NIVEAU_2)
    end
  end

  context "lorsqu'il y a trois pièces ratées" do
    it 'a le niveau 1' do
      expect(evaluation).to receive(:nombre_ratees).and_return(3)
      expect(
        described_class.new(evaluation).niveau
      ).to eql(Competence::NIVEAU_1)
    end
  end
end
