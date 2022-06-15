# frozen_string_literal: true

require 'rails_helper'

describe Restitution::CafeDeLaPlace do
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:situation) { create :situation }
  let(:campagne) { build :campagne }
  let(:restitution) do
    described_class.new(campagne,
                        [
                          build(:evenement_demarrage, partie: partie),
                          build(:evenement_reponse, partie: partie,
                                                    donnees: { question: 'question' }),
                          build(:evenement_reponse,
                                donnees: { succes: true,
                                           question: 'LOdi1',
                                           score: 1 },
                                partie: partie)
                        ])
  end

  describe '#parcours_bas' do
    it 'quand le profil lecture_bas est le plus petit' do
      expect(restitution).to receive(:competences)
        .and_return({
                      lecture_bas: :profil1,
                      comprehension: :profil2,
                      production: :profil3
                    })
      expect(restitution.parcours_bas).to equal(:profil1)
    end

    it 'quand le profil comprehension est le plus petit' do
      expect(restitution).to receive(:competences)
        .and_return({
                      lecture_bas: :profil3,
                      comprehension: :profil2,
                      production: :profil4
                    })
      expect(restitution.parcours_bas).to equal(:profil2)
    end

    it "quand un profil n'est pas définit" do
      expect(restitution).to receive(:competences)
        .and_return({
                      lecture_bas: ::Competence::NIVEAU_INDETERMINE,
                      comprehension: :profil2,
                      production: :profil4
                    })
      expect(restitution.parcours_bas).to equal(::Competence::NIVEAU_INDETERMINE)
    end
  end

  describe '#persiste' do
    context "persiste l'ensemble des données de la partie" do
      it do
        restitution.persiste
        partie.reload
        expect(partie.metriques['score_orientation']).to eq 1
      end
    end
  end
end
