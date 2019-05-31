# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Tri::Rapidite do
  let(:evaluation) { double }

  def pour(termine: nil, secondes: nil)
    allow(evaluation).to receive(:temps_total).and_return(secondes)
    allow(evaluation).to receive(:termine?).and_return(termine)
    described_class.new(evaluation)
  end

  it { expect(pour(termine: false)).to evalue_a(Competence::NIVEAU_INDETERMINE) }
  it { expect(pour(termine: true, secondes: 120)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(termine: true, secondes: 121)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(termine: true, secondes: 180)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(termine: true, secondes: 181)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(termine: true, secondes: 240)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(termine: true, secondes: 241)).to evalue_a(Competence::NIVEAU_1) }
end
