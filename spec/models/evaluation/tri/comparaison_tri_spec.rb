# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Tri::ComparaisonTri do
  def pour(erreurs: nil)
    evaluation = double
    allow(evaluation).to receive(:nombre_mal_placees).and_return(erreurs)
    described_class.new(evaluation)
  end

  it { expect(pour(erreurs: 0)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(erreurs: 1)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(erreurs: 2)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(erreurs: 3)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(erreurs: 4)).to evalue_a(Competence::NIVEAU_1) }
  it { expect(pour(erreurs: 9)).to evalue_a(Competence::NIVEAU_1) }
end
