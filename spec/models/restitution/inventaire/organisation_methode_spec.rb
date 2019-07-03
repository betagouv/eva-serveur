# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Inventaire::OrganisationMethode do
  let(:restitution) { double }

  context 'en réussite et moins de 70 ouvertures de contenants' do
    it 'a le niveau 4' do
      expect(restitution).to receive(:reussite?).and_return(true)
      expect(restitution).to receive(:nombre_ouverture_contenant).and_return(60)
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_4)
    end
  end

  context 'en réussite et entre de 70 et 120 ouvertures de contenants' do
    it 'a le niveau 3' do
      expect(restitution).to receive(:reussite?).and_return(true)
      expect(restitution).to receive(:nombre_ouverture_contenant).and_return(80)
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_3)
    end
  end

  context 'en réussite et entre de 120 et 250 ouvertures de contenants' do
    it 'a le niveau 2' do
      expect(restitution).to receive(:reussite?).and_return(true)
      expect(restitution).to receive(:nombre_ouverture_contenant).and_return(200)
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_2)
    end
  end

  context 'en réussite et plus de 250 ouvertures de contenants' do
    it 'a le niveau 2' do
      expect(restitution).to receive(:reussite?).and_return(true)
      expect(restitution).to receive(:nombre_ouverture_contenant).and_return(300)
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_1)
    end
  end

  context 'en cas de non reussite' do
    it 'a le niveau indetermine' do
      expect(restitution).to receive(:reussite?).and_return(false)
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_INDETERMINE)
    end
  end
end
