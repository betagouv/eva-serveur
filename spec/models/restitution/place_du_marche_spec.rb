# frozen_string_literal: true

require 'rails_helper'

describe Restitution::PlaceDuMarche do
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let(:situation) { create :situation }
  let(:campagne) { build :campagne }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:restitution) do
    described_class.new(campagne,
                        [
                          build(:evenement_demarrage, partie: partie),
                          build(:evenement_reponse, partie: partie,
                                                    donnees: { question: 'question' }),
                          build(:evenement_reponse,
                                donnees: { succes: true,
                                           question: 'N1PQ2',
                                           score: 1 },
                                partie: partie),
                          build(:evenement_reponse,
                                donnees: { succes: true,
                                           question: 'NumeratieN2Q1',
                                           score: 0.5 },
                                partie: partie),
                          build(:evenement_reponse,
                                donnees: { succes: false,
                                           question: 'NumeratieN3Q1' },
                                partie: partie)
                        ])
  end

  describe '#synthèse' do
    it 'retourne la synthèse des score des niveaux évalués' do
      evenements = [
        build(:evenement_demarrage)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.synthese.keys).to eql(%i[numeratie_niveau1
                                                  numeratie_niveau2
                                                  numeratie_niveau3])
    end
  end

  describe '#score_niveau1' do
    it 'retourne le score du niveau 1' do
      expect(restitution.score_niveau1).to eq 1
    end
  end

  describe '#score_niveau2' do
    it 'retourne le score du niveau 2' do
      expect(restitution.score_niveau2).to eq(0.5)
    end
  end

  describe '#score_niveau3' do
    it 'retourne le score du niveau 3' do
      expect(restitution.score_niveau3).to eq(0)
    end
  end
end
