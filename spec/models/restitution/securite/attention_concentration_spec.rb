require 'rails_helper'

describe Restitution::Securite::AttentionConcentration do
  let(:restitution) { double }

  def niveau_pour_score(score)
    expect(restitution).to receive(:cote_z_metriques)
      .and_return('temps_moyen_recherche_zones_dangers' => score)

    described_class.new(restitution)
  end

  context 'sans abandon' do
    before { allow(restitution).to receive(:abandon?).and_return(false) }

    it { expect(niveau_pour_score(nil)).to evalue_a(Competence::NIVEAU_INDETERMINE) }
    it { expect(niveau_pour_score(-0.1)).to evalue_a(Competence::NIVEAU_4) }
    it { expect(niveau_pour_score(0)).to evalue_a(Competence::NIVEAU_3) }
    it { expect(niveau_pour_score(0.49)).to evalue_a(Competence::NIVEAU_3) }
    it { expect(niveau_pour_score(0.5)).to evalue_a(Competence::NIVEAU_2) }
    it { expect(niveau_pour_score(0.99)).to evalue_a(Competence::NIVEAU_2) }
    it { expect(niveau_pour_score(1)).to evalue_a(Competence::NIVEAU_1) }
  end

  context 'avec abandon' do
    it 'a un niveau indeterminé' do
      expect(restitution).to receive(:abandon?).and_return(true)
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_INDETERMINE)
    end
  end
end
