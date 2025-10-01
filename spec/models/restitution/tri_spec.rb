require 'rails_helper'

describe Restitution::Tri do
  let(:campagne) { build :campagne }
  let(:restitution) { described_class.new(campagne, evenements) }

  context 'avec toutes les pieces enregistrées' do
    let(:evenements) do
      [
        build(:evenement_demarrage),
        build(:evenement_piece_mal_placee),
        *Array.new(Restitution::Tri::PIECES_TOTAL) do
          build(:evenement_piece_bien_placee)
        end
      ]
    end

    it { expect(restitution).to be_termine }
  end

  context "avec l'événement de fin de situation" do
    let(:evenements) do
      [
        build(:evenement_demarrage),
        build(:evenement_fin_situation)
      ]
    end

    it { expect(restitution).to be_termine }
  end

  context 'avec pas toutes les pieces enregistrées' do
    let(:evenements) do
      [
        build(:evenement_demarrage),
        *Array.new(4) do
          build(:evenement_piece_bien_placee)
        end
      ]
    end

    it { expect(restitution).not_to be_termine }
    it { expect(restitution.nombre_non_triees).to eq(Restitution::Tri::PIECES_TOTAL - 4) }
  end

  context 'compter les pièces bien placées' do
    let(:evenements) do
      [
        build(:evenement_piece_bien_placee),
        build(:evenement_piece_mal_placee)
      ]
    end

    it { expect(restitution.nombre_bien_placees).to eq(1) }
  end

  context 'compter les pièces mal placées' do
    let(:evenements) do
      [
        build(:evenement_piece_mal_placee),
        build(:evenement_piece_mal_placee)
      ]
    end

    it { expect(restitution.nombre_mal_placees).to eq(2) }
  end

  describe '#competences' do
    it 'retourne les compétences évaluées' do
      evenements = [
        build(:evenement_demarrage)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.competences.keys).to eql([ Competence::PERSEVERANCE,
                                                   Competence::COMPREHENSION_CONSIGNE,
                                                   Competence::RAPIDITE,
                                                   Competence::COMPARAISON_TRI ])
    end
  end
end
