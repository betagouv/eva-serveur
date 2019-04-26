# frozen_string_literal: true

require 'rails_helper'

describe EvaluationControle do
  let(:evaluation) { described_class.new(evenements) }

  context 'compter les pièces bien placées' do
    let(:evenements) do
      [
        build(:evenement_piece_bien_placee),
        build(:evenement_piece_mal_placee)
      ]
    end

    it { expect(evaluation.nombre_bien_placees).to eq(1) }
  end

  context 'compter les pièces mal placées' do
    let(:evenements) do
      [
        build(:evenement_piece_mal_placee),
        build(:evenement_piece_mal_placee)
      ]
    end

    it { expect(evaluation.nombre_mal_placees).to eq(2) }
  end

  context 'compter les pièces ratées' do
    let(:evenements) do
      [
        build(:evenement_piece_ratee)
      ]
    end

    it { expect(evaluation.nombre_ratees).to eq(1) }
  end

  context 'filtrer les événements pièces' do
    let(:evenements_pieces) do
      [
        build(:evenement_piece_bien_placee),
        build(:evenement_piece_mal_placee),
        build(:evenement_piece_ratee)
      ]
    end

    let(:evenements) do
      [
        build(:evenement_demarrage),
        *evenements_pieces
      ]
    end

    it { expect(evaluation.evenements_pieces).to eq(evenements_pieces) }
  end
end
