# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Tri::ComparaisonTri do
  def pour(termine: nil, erreurs: nil)
    evaluation = double
    allow(evaluation).to receive(:termine?).and_return(termine)
    allow(evaluation).to receive(:nombre_mal_placees).and_return(erreurs)
    described_class.new(evaluation)
  end

  it { expect(pour(termine: true, erreurs: 0)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(termine: true, erreurs: 1)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(termine: true, erreurs: 2)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(termine: true, erreurs: 3)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(termine: true, erreurs: 4)).to evalue_a(Competence::NIVEAU_1) }
  it { expect(pour(termine: true, erreurs: 9)).to evalue_a(Competence::NIVEAU_1) }
  it { expect(pour(termine: false, erreurs: 0)).to evalue_a(Competence::NIVEAU_INDETERMINE) }
end
