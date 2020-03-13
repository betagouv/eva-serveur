# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Maintenance::Vocabulaire do
  let(:restitution) { double }

  def niveau_pour_score(score)
    allow(restitution).to receive(:score).and_return(score)

    described_class.new(restitution)
  end

  it { expect(niveau_pour_score(-0.39)).to evalue_a(Competence::NIVEAU_1) }
  it { expect(niveau_pour_score(-0.4)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(niveau_pour_score(-1.99)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(niveau_pour_score(-2)).to evalue_a(Competence::NIVEAU_3) }
end
