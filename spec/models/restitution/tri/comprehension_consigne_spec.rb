require 'rails_helper'

describe Restitution::Tri::ComprehensionConsigne do
  let(:restitution) { double }

  def pour(termine: nil, jouees: nil, erreurs: nil, relectures: nil)
    bien_placees = jouees || 0
    bien_placees -= erreurs if erreurs
    allow(restitution).to receive_messages(termine?: termine, nombre_bien_placees: bien_placees,
                                           nombre_mal_placees: erreurs, nombre_rejoue_consigne: relectures)
    described_class.new(restitution)
  end

  it { expect(pour(termine: true, erreurs: 7)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(termine: true, erreurs: 8)).to evalue_a(Competence::NIVEAU_INDETERMINE) }

  it do
    expect(pour(termine: false, jouees: 7, erreurs: 1, relectures: 1))
      .to evalue_a(Competence::NIVEAU_1)
  end

  it do
    expect(pour(termine: false, jouees: 7, erreurs: 1, relectures: 2))
      .to evalue_a(Competence::NIVEAU_1)
  end

  it do
    expect(pour(termine: false, jouees: 7, erreurs: 0, relectures: 1))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end

  it do
    expect(pour(termine: false, jouees: 7, erreurs: 1, relectures: 0))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end

  it do
    expect(pour(termine: false, jouees: 8, erreurs: 1, relectures: 1))
      .to evalue_a(Competence::NIVEAU_INDETERMINE)
  end
end
