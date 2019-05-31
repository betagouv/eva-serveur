# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Tri::Rapidite do
  let(:evaluation) { double }

  def pour(secondes: nil)
    allow(evaluation).to receive(:temps_total).and_return(secondes)
    described_class.new(evaluation)
  end

  it { expect(pour(secondes: 120)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(secondes: 121)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(secondes: 180)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(secondes: 181)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(secondes: 240)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(secondes: 241)).to evalue_a(Competence::NIVEAU_1) }
end
