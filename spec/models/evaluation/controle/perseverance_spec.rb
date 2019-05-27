# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Controle::Perseverance do
  let(:evaluation) { double }

  def pour(termine: nil, nombre_pieces: nil, nombre_bien_placees: nil)
    allow(evaluation).to receive(:termine?).and_return(termine)
    allow(evaluation).to receive(:nombre_bien_placees).and_return(nombre_bien_placees)
    evenements_pieces = Array.new(nombre_pieces) if nombre_pieces
    allow(evaluation).to receive(:evenements_pieces).and_return(evenements_pieces)
    described_class.new(evaluation)
  end

  it { expect(pour(termine: true)).to evalue_a(Competence::NIVEAU_4) }
  it {
    expect(pour(termine: false, nombre_pieces: 15, nombre_bien_placees: 8))
      .to evalue_a(Competence::NIVEAU_1)
  }
  it {
    expect(pour(termine: false, nombre_pieces: 14, nombre_bien_placees: 8))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  }

  it {
    expect(pour(termine: false, nombre_pieces: 15, nombre_bien_placees: 7))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  }
end
