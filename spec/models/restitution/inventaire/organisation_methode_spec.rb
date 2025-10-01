require 'rails_helper'

describe Restitution::Inventaire::OrganisationMethode do
  let(:restitution) { double }

  def verifie_niveau(nombre_ouvertures, niveau_attendu)
    expect(restitution).to receive(:nombre_ouverture_contenant).and_return(nombre_ouvertures)
    expect(
      described_class.new(restitution).niveau
    ).to eql(niveau_attendu)
  end

  context 'en cas de réussite' do
    before { allow(restitution).to receive(:reussite?).and_return(true) }

    describe "pour la version originale de l'inventaire" do
      before { allow(restitution).to receive(:version?).and_return(false) }

      it { verifie_niveau(70, Competence::NIVEAU_4) }
      it { verifie_niveau(71, Competence::NIVEAU_3) }
      it { verifie_niveau(120, Competence::NIVEAU_3) }
      it { verifie_niveau(121, Competence::NIVEAU_2) }
      it { verifie_niveau(250, Competence::NIVEAU_2) }
      it { verifie_niveau(251, Competence::NIVEAU_1) }
    end

    describe "pour la version 2 de l'inventaire" do
      before { allow(restitution).to receive(:version?).with('2').and_return(true) }

      it { verifie_niveau(42, Competence::NIVEAU_4) }
      it { verifie_niveau(43, Competence::NIVEAU_3) }
      it { verifie_niveau(71, Competence::NIVEAU_3) }
      it { verifie_niveau(72, Competence::NIVEAU_2) }
      it { verifie_niveau(148, Competence::NIVEAU_2) }
      it { verifie_niveau(149, Competence::NIVEAU_1) }
    end
  end

  context 'en cas de non réussite' do
    before { allow(restitution).to receive(:reussite?).and_return(false) }

    it 'a le niveau indéterminé' do
      expect(
        described_class.new(restitution).niveau
      ).to eql(Competence::NIVEAU_INDETERMINE)
    end
  end
end
