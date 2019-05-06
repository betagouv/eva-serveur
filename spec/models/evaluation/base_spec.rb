# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Base do
  let(:evaluation) { described_class.new(evenements) }

  context 'lorsque le dernier événement est stop' do
    let(:evenements) do
      [
        build(:evenement_piece_bien_placee),
        build(:evenement_piece_mal_placee),
        build(:evenement_stop)
      ]
    end

    it { expect(evaluation.abandon?).to be(true) }
  end

  it 'renvoie le nombre de réécoute de la consigne' do
    evenements = [
      build(:evenement_demarrage),
      build(:evenement_rejoue_consigne),
      build(:evenement_rejoue_consigne)
    ]
    expect(described_class.new(evenements).nombre_rejoue_consigne).to eql(2)
  end

  it 'envoie une exception not implemented pour la méthode termine?' do
    expect do
      described_class.new([]).termine?
    end.to raise_error(NotImplementedError)
  end

  it 'renvoie par défaut une liste vide pour les compétences évaluées' do
    expect(described_class.new([]).competences).to eql({})
  end
end
