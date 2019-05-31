# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Tri::ComprehensionConsigne do
  let(:evaluation) { double }

  def pour(termine: nil, erreurs: nil, relectures: nil)
    allow(evaluation).to receive(:termine?).and_return(termine)
    allow(evaluation).to receive(:nombre_mal_placees).and_return(erreurs)
    allow(evaluation).to receive(:nombre_rejoue_consigne).and_return(relectures)
    described_class.new(evaluation)
  end

  it { expect(pour(termine: true, erreurs: 7)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(termine: true, erreurs: 8)).to evalue_a(Competence::NIVEAU_INDETERMINE) }

  it { expect(pour(termine: false, erreurs: 7, relectures: 2)).to evalue_a(Competence::NIVEAU_1) }
  it do
    expect(pour(termine: false, erreurs: 8, relectures: 2))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end
  it do
    expect(pour(termine: false, erreurs: 7, relectures: 1))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end
end
