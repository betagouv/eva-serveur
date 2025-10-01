require 'rails_helper'

describe Restitution::Controle::ComprehensionConsigne do
  let(:restitution) { double }

  it 'a terminé en moins de 15 erreurs ou de ratées: niveau 4' do
    allow(restitution).to receive_messages(termine?: true, nombre_bien_placees: 36,
                                           nombre_loupees: 14)
    expect(
      described_class.new(restitution).niveau
    ).to eql(Competence::NIVEAU_4)
  end

  it 'a terminé en plus de 15 loupés: niveau 1' do
    allow(restitution).to receive_messages(termine?: true, nombre_loupees: 16,
                                           nombre_bien_placees: 44)
    expect(
      described_class.new(restitution).niveau
    ).to eql(Competence::NIVEAU_1)
  end

  it 'a réécouté la consigne, a fait des erreurs en triant 10 biscuits et abandon: niveau 1' do
    allow(restitution).to receive_messages(termine?: false, abandon?: true,
                                           nombre_rejoue_consigne: 1, nombre_loupees: 8, nombre_bien_placees: 1)
    expect(
      described_class.new(restitution).niveau
    ).to eql(Competence::NIVEAU_1)
  end

  it "a réécouté la consigne, pas d'erreur et abandon : indéterminé" do
    allow(restitution).to receive_messages(termine?: false, abandon?: true, nombre_bien_placees: 9,
                                           nombre_rejoue_consigne: 1, nombre_loupees: 0)
    expect(
      described_class.new(restitution).niveau
    ).to eql(Competence::NIVEAU_INDETERMINE)
  end

  it 'en abandonnant après > 10 biscuits: niveau indeterminé' do
    allow(restitution).to receive_messages(termine?: false, abandon?: true, nombre_loupees: 22,
                                           nombre_bien_placees: 1)
    expect(
      described_class.new(restitution).niveau
    ).to eql(Competence::NIVEAU_INDETERMINE)
  end
end
