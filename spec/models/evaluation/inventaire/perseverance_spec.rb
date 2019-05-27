# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Inventaire::Perseverance do
  let(:evaluation) { double }

  def pour(reussite: nil, nombre_essais: nil, minutes: nil, erreurs: nil)
    secondes = minutes.minutes.to_i if minutes
    expect(evaluation).to receive(:reussite?).and_return(reussite)
    essai = double
    allow(essai).to receive(:nombre_erreurs).and_return(erreurs)
    allow(evaluation).to receive(:essais).and_return([essai])
    allow(evaluation).to receive(:nombre_essais_validation).and_return(nombre_essais)
    allow(evaluation).to receive(:temps_total).and_return(secondes)
    described_class.new(evaluation)
  end

  it { expect(pour(reussite: true, minutes: 23)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(reussite: true, minutes: 22)).to evalue_a(Competence::NIVEAU_INDETERMINE) }

  it { expect(pour(reussite: false, nombre_essais: 0)).to evalue_a(Competence::NIVEAU_INDETERMINE) }
  it { expect(pour(reussite: false, nombre_essais: 1)).to evalue_a(Competence::NIVEAU_1) }

  it {
    expect(pour(reussite: false, nombre_essais: 2, minutes: 21, erreurs: 7))
      .to evalue_a(Competence::NIVEAU_1)
  }
  it {
    expect(pour(reussite: false, nombre_essais: 2, minutes: 21, erreurs: 8))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  }
  it {
    expect(pour(reussite: false, nombre_essais: 2, minutes: 22, erreurs: 7))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  }
end
