# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Tri::Perseverance do
  let(:restitution) { double }

  def pour(termine: nil, secondes: nil, erreurs: nil)
    allow(restitution).to receive_messages(termine?: termine, nombre_mal_placees: erreurs,
                                           temps_total: secondes)
    described_class.new(restitution)
  end

  it { expect(pour(termine: true, secondes: 241, erreurs: 6)).to evalue_a(Competence::NIVEAU_4) }

  it do
    expect(pour(termine: true, secondes: 241, erreurs: 5))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end

  it do
    expect(pour(termine: true, secondes: 240, erreurs: 6))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end

  it { expect(pour(termine: false, secondes: 119, erreurs: 4)).to evalue_a(Competence::NIVEAU_1) }

  it do
    expect(pour(termine: true, secondes: 119, erreurs: 4))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end

  it do
    expect(pour(termine: false, secondes: 120, erreurs: 4))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end

  it do
    expect(pour(termine: false, secondes: 119, erreurs: 3))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end
end
