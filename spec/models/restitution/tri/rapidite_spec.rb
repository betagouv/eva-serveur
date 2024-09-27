# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Tri::Rapidite do
  let(:restitution) { double }

  def pour(termine: nil, secondes: nil)
    allow(restitution).to receive_messages(temps_total: secondes, termine?: termine)
    described_class.new(restitution)
  end

  it { expect(pour(termine: false)).to evalue_a(Competence::NIVEAU_INDETERMINE) }
  it { expect(pour(termine: true, secondes: 120)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(termine: true, secondes: 121)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(termine: true, secondes: 180)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(termine: true, secondes: 181)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(termine: true, secondes: 240)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(termine: true, secondes: 241)).to evalue_a(Competence::NIVEAU_1) }
end
