# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Tri::ComparaisonTri do
  def pour(termine: nil, erreurs: nil)
    restitution = double
    allow(restitution).to receive_messages(termine?: termine, nombre_mal_placees: erreurs)
    described_class.new(restitution)
  end

  it { expect(pour(termine: true, erreurs: 0)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(termine: true, erreurs: 1)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(termine: true, erreurs: 2)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(termine: true, erreurs: 3)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(termine: true, erreurs: 4)).to evalue_a(Competence::NIVEAU_1) }
  it { expect(pour(termine: true, erreurs: 9)).to evalue_a(Competence::NIVEAU_1) }
  it { expect(pour(termine: false, erreurs: 0)).to evalue_a(Competence::NIVEAU_INDETERMINE) }
end
