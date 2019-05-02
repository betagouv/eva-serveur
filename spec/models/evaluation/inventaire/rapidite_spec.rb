# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Inventaire::Rapidite do
  let(:evaluation) { double }

  def self.reussite_avec_temps(secondes, niveau)
    it "en réussite et en #{secondes / 60} minutes: niveau #{niveau}" do
      expect(evaluation).to receive(:reussite?).and_return(true)
      expect(evaluation).to receive(:temps_total).and_return(secondes.to_i)
      expect(described_class.new(evaluation).niveau).to eql(niveau)
    end
  end

  reussite_avec_temps(0.minutes, Competence::NIVEAU_4)
  reussite_avec_temps(10.minutes, Competence::NIVEAU_4)
  reussite_avec_temps(11.minutes, Competence::NIVEAU_3)
  reussite_avec_temps(15.minutes, Competence::NIVEAU_3)
  reussite_avec_temps(16.minutes, Competence::NIVEAU_2)
  reussite_avec_temps(30.minutes, Competence::NIVEAU_2)
  reussite_avec_temps(31.minutes, Competence::NIVEAU_1)

  it 'en cas de non réussite: niveau indéterminé' do
    expect(evaluation).to receive(:reussite?).and_return(false)
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_INDETERMINE)
  end
end
