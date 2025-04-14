# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Controle do
  let(:campagne) { build :campagne }
  let(:restitution) { described_class.new(campagne, evenements) }

  context 'avec toutes les pieces enregistrées' do
    let(:evenements) do
      [
        build(:evenement_demarrage),
        *Array.new(60) do
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

  context 'compter les pièces non triées' do
    let(:evenements) do
      [
        build(:evenement_piece_non_triee)
      ]
    end

    it { expect(restitution.nombre_non_triees).to eq(1) }
  end

  context 'compter les pièces loupées' do
    let(:evenements) do
      [
        build(:evenement_piece_mal_placee),
        build(:evenement_piece_bien_placee),
        build(:evenement_piece_non_triee)
      ]
    end

    it { expect(restitution.nombre_loupees).to eq(2) }
  end

  context 'filtrer les événements pièces' do
    let(:evenements_pieces) do
      [
        build(:evenement_piece_bien_placee),
        build(:evenement_piece_mal_placee),
        build(:evenement_piece_non_triee)
      ]
    end

    let(:evenements) do
      [
        build(:evenement_demarrage),
        *evenements_pieces
      ]
    end

    it { expect(restitution.evenements_pieces).to eq(evenements_pieces) }
  end

  describe '#enleve_premiers_evenements_pieces' do
    let(:demarrage) { build(:evenement_demarrage) }
    let(:bien_placee) { build(:evenement_piece_bien_placee) }
    let(:evenements) do
      [
        demarrage,
        build(:evenement_piece_non_triee),
        build(:evenement_piece_mal_placee),
        bien_placee
      ]
    end

    it 'retourne une instance RestitutionControle' do
      expect(restitution.enleve_premiers_evenements_pieces(2)).to be_a(described_class)
    end

    it 'enlève tout les événements de pièces' do
      expect(restitution.enleve_premiers_evenements_pieces(4).evenements).to eql([ demarrage ])
    end

    it 'enlève les x premiers événements de pièces' do
      restitution.enleve_premiers_evenements_pieces(2).evenements.tap do |evenements|
        expect(evenements).to eql([ demarrage, bien_placee ])
      end
    end
  end

  describe '#competences' do
    let(:evenements) { [ build(:evenement_demarrage) ] }

    it 'retourne les compétences évaluées' do
      expect(restitution.competences.keys).to eql([ Competence::PERSEVERANCE,
                                                   Competence::COMPREHENSION_CONSIGNE,
                                                   Competence::RAPIDITE,
                                                   Competence::COMPARAISON_TRI,
                                                   Competence::ATTENTION_CONCENTRATION ])
    end
  end
end
