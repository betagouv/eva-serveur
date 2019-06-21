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

  describe '#efficience' do
    let(:evaluation) { described_class.new([]) }

    it "retourne l'efficience sans les compétences persévérance et compréhension consigne" do
      expect(evaluation).to receive(:competences).and_return(
        ::Competence::PERSEVERANCE => Competence::NIVEAU_1,
        ::Competence::COMPREHENSION_CONSIGNE => Competence::NIVEAU_1,
        ::Competence::RAPIDITE => Competence::NIVEAU_3,
        ::Competence::COMPARAISON_TRI => Competence::NIVEAU_4,
        ::Competence::ATTENTION_CONCENTRATION => Competence::NIVEAU_4
      )
      expect(evaluation.efficience).to eql(91)
    end

    it 'retourne une efficience indéterminé si une compétences indéterminé' do
      expect(evaluation).to receive(:competences).and_return(
        ::Competence::RAPIDITE => Competence::NIVEAU_1,
        ::Competence::COMPARAISON_TRI => Competence::NIVEAU_INDETERMINE,
        ::Competence::ATTENTION_CONCENTRATION => Competence::NIVEAU_2
      )
      expect(evaluation.efficience).to eql(::Competence::NIVEAU_INDETERMINE)
    end

    it "retourne 0 lorsque rien n'a été mesuré" do
      expect(evaluation).to receive(:competences).and_return({})
      expect(evaluation.efficience).to eql(0)
    end
  end

  describe '#supprimer' do
    let(:evenements) do
      [
        create(:evenement_demarrage),
        create(:evenement_stop)
      ]
    end

    let(:where) { double }

    it "supprime les événements de l'évaluation" do
      expect(where).to receive(:delete_all)
      expect(Evenement).to receive(:where)
        .with(id: [evenements[0].id, evenements[1].id])
        .and_return(where)
      evaluation.supprimer
    end
  end
end
