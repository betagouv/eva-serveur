# frozen_string_literal: true

require 'rails_helper'

describe Restitution::PlaceDuMarche do
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let(:situation) { create :situation }
  let(:campagne) { build :campagne }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:restitution) do
    described_class.new(
      campagne,
      [
        build(:evenement_demarrage, partie: partie),
        build(:evenement_reponse, partie: partie, donnees: { question: 'question' }),
        build(:evenement_reponse,
              donnees: { succes: true, question: 'N1Prn1', scoreMax: 1, score: 1 },
              partie: partie),
        build(:evenement_reponse,
              donnees: { succes: true, question: 'N2Q1', score: 0.5, scoreMax: 0.5 },
              partie: partie),
        build(:evenement_reponse,
              donnees: { succes: false, question: 'N2Q2', score: 0, scoreMax: 0.5 },
              partie: partie),
        build(:evenement_reponse,
              donnees: { succes: false, scoreMax: 1, question: 'N3Q1' },
              partie: partie)
      ]
    )
  end

  describe '#synthèse' do
    it 'retourne la synthèse des score des niveaux évalués et le profil' do
      evenements = [
        build(:evenement_demarrage)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.synthese.keys).to eql(%i[numeratie_niveau1
                                                  numeratie_niveau2
                                                  numeratie_niveau3
                                                  profil_numeratie])
    end
  end

  describe '#score_pour' do
    context 'sans rattrapage' do
      let(:restitution) do
        described_class.new(campagne,
                            [
                              build(:evenement_demarrage, partie: partie),
                              build(:evenement_reponse,
                                    donnees: { succes: true,
                                               question: 'N1Pse1',
                                               score: 1 },
                                    partie: partie),
                              build(:evenement_reponse,
                                    donnees: { succes: true,
                                               question: 'N1Pvn1',
                                               score: 1 },
                                    partie: partie),
                              build(:evenement_reponse,
                                    donnees: { succes: true,
                                               question: 'N1Prn1',
                                               score: 1 },
                                    partie: partie),
                              build(:evenement_reponse,
                                    donnees: { succes: true,
                                               question: 'N2',
                                               score: 0.5 },
                                    partie: partie)
                            ])
      end

      it 'retourne le score selon le niveau' do
        expect(restitution.score_pour(:N1)).to eq 3
        expect(restitution.score_pour(:N2)).to eq(0.5)
        expect(restitution.score_pour(:N3)).to eq(nil)
      end
    end

    context 'avec du rattrapage' do
      let(:restitution) do
        described_class.new(campagne,
                            [
                              build(:evenement_demarrage, partie: partie),
                              build(:evenement_reponse, donnees: { succes: true,
                                                                   question: 'N1Pse1',
                                                                   score: 1 },
                                                        partie: partie),
                              build(:evenement_reponse, donnees: { succes: true,
                                                                   question: 'N1Pvn1',
                                                                   score: 1 },
                                                        partie: partie),
                              build(:evenement_reponse, donnees: { succes: true,
                                                                   question: 'N1Prn1',
                                                                   score: 1 },
                                                        partie: partie),
                              build(:evenement_reponse, donnees: { succes: true,
                                                                   question: 'N1Rrn1',
                                                                   score: 2 },
                                                        partie: partie),
                              build(:evenement_reponse, donnees: { succes: true,
                                                                   question: 'N2',
                                                                   score: 0.5 },
                                                        partie: partie)
                            ])
      end

      it 'retourne le score du niveau donné' do
        expect(restitution.score_pour(:N1)).to eq 4
      end
    end
  end

  describe '#pourcentage_de_reussite_pour' do
    it 'retourne le pourcentage de réussite pour un niveau donné' do
      expect(restitution.pourcentage_de_reussite_pour(:N1)).to eq(100)
      expect(restitution.pourcentage_de_reussite_pour(:N2)).to eq(50)
      expect(restitution.pourcentage_de_reussite_pour(:N3)).to eq(0)
    end
  end

  describe '#profil_numeratie' do
    context 'quand le niveau numératie est 1' do
      before do
        allow(restitution).to receive(:niveau_numeratie).and_return 1
      end

      it 'retourne le profil 1' do
        expect(restitution.profil_numeratie).to equal(Competence::PROFIL_1)
      end
    end

    context 'quand le niveau numératie est 2' do
      before do
        allow(restitution).to receive(:niveau_numeratie).and_return 2
      end

      it 'retourne le profil 2' do
        expect(restitution.profil_numeratie).to equal(Competence::PROFIL_2)
      end
    end

    context 'quand le niveau numératie est 3' do
      before do
        allow(restitution).to receive(:niveau_numeratie).and_return 3
      end

      it 'retourne le profil 3' do
        expect(restitution.profil_numeratie).to equal(Competence::PROFIL_3)
      end
    end

    context 'quand le niveau numératie est 4' do
      before do
        allow(restitution).to receive(:niveau_numeratie).and_return 4
      end

      it 'retourne le profil 4' do
        expect(restitution.profil_numeratie).to equal(Competence::PROFIL_4)
      end
    end

    context "quand il n'y a pas de niveau littératie" do
      before do
        allow(restitution).to receive(:niveau_numeratie).and_return nil
      end

      it 'retourne le profil indéterminé' do
        expect(restitution.profil_numeratie).to equal(Competence::NIVEAU_INDETERMINE)
      end
    end
  end

  describe '#niveau_numeratie' do
    context 'quand le pourcentage de réussite pour N1 est nil' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return nil
      end

      it 'retourne nil' do
        expect(restitution.niveau_numeratie).to eq nil
      end
    end

    context 'quand le pourcentage de réussite pour N1 est inférieur à 70 et N2 est nil' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 59
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return nil
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N3).and_return nil
      end

      it 'retourne 1' do
        expect(restitution.niveau_numeratie).to eq 1
      end
    end

    context 'quand le pourcentage de réussite pour N2 est inférieur à 70 et N3 est nil' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return 59
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N3).and_return nil
      end

      it 'retourne 2' do
        expect(restitution.niveau_numeratie).to eq 2
      end
    end

    context 'quand le pourcentage de réussite pour N3 est inférieur à 70' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N3).and_return 59
      end

      it 'retourne 3' do
        expect(restitution.niveau_numeratie).to eq 3
      end
    end

    context 'quand le pourcentage de réussite pour N3 est supérieur à 70' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N3).and_return 71
      end

      it 'retourne 4' do
        expect(restitution.niveau_numeratie).to eq 4
      end
    end
  end
end
