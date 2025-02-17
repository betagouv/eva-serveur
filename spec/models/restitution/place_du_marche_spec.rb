# frozen_string_literal: true

require 'rails_helper'

describe Restitution::PlaceDuMarche do
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let!(:situation) { create :situation_place_du_marche }
  let(:campagne) { build :campagne }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:evenements) do
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
  end
  let(:restitution) do
    described_class.new(
      campagne, evenements
    )
  end

  describe '#synthèse' do
    it 'retourne la synthèse des score des niveaux évalués et le profil' do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(
        :calcule_pourcentage_reussite_competence_clea
      )
      # rubocop:enable RSpec/AnyInstance
      restitution = described_class.new(campagne, evenements)
      expect(restitution.synthese.keys).to eql(%i[numeratie_niveau1
                                                  numeratie_niveau2
                                                  numeratie_niveau3
                                                  profil_numeratie])
    end
  end

  describe '#score_pour' do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(
        :calcule_pourcentage_reussite_competence_clea
      )
      # rubocop:enable RSpec/AnyInstance
    end

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
                                               question: 'N2Pom',
                                               score: 0.5 },
                                    partie: partie)
                            ])
      end

      it 'retourne le score selon le niveau' do
        expect(restitution.score_pour(:N1)).to eq 3
        expect(restitution.score_pour(:N2)).to eq(0.5)
        expect(restitution.score_pour(:N3)).to be_nil
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
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(
        :calcule_pourcentage_reussite_competence_clea
      )
      # rubocop:enable RSpec/AnyInstance
    end

    it 'retourne le pourcentage de réussite pour un niveau donné' do
      expect(restitution.pourcentage_de_reussite_pour(:N1)).to eq(6.25)
      expect(restitution.pourcentage_de_reussite_pour(:N2)).to eq(2.5)
      expect(restitution.pourcentage_de_reussite_pour(:N3)).to eq(0)
    end
  end

  describe '#profil_numeratie' do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(
        :calcule_pourcentage_reussite_competence_clea
      )
      # rubocop:enable RSpec/AnyInstance
    end

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

    context 'quand le niveau numératie est 5 (4 Plus)' do
      before do
        allow(restitution).to receive(:niveau_numeratie).and_return 5
      end

      it 'retourne le profil 4 Plus' do
        expect(restitution.profil_numeratie).to equal(Competence::PROFIL_4_PLUS)
      end
    end

    context 'quand le niveau numératie est 0' do
      before do
        allow(restitution).to receive(:niveau_numeratie).and_return 0
      end

      it 'retourne le profil indéterminé' do
        expect(restitution.profil_numeratie).to equal(Competence::NIVEAU_INDETERMINE)
      end
    end
  end

  describe '#niveau_numeratie' do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(
        :calcule_pourcentage_reussite_competence_clea
      )
      # rubocop:enable RSpec/AnyInstance
      allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return nil
      allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return nil
      allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N3).and_return nil
    end

    context 'quand le pourcentage de réussite pour N1 est nil' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return nil
      end

      it { expect(restitution.niveau_numeratie).to eq 0 }
    end

    context 'quand le pourcentage de réussite pour N1 est inférieur à 70 et N2 est nil' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 59
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return nil
      end

      it { expect(restitution.niveau_numeratie).to eq 1 }
    end

    context 'quand le pourcentage de réussite pour N1 est supérieur à 70 et N2 est nil' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return nil
      end

      it { expect(restitution.niveau_numeratie).to eq 1 }
    end

    context 'quand le pourcentage de réussite pour N2 est inférieur à 70 et N3 est nil' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return 59
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N3).and_return nil
      end

      it { expect(restitution.niveau_numeratie).to eq 2 }
    end

    context 'quand le pourcentage de réussite pour N3 est inférieur à 70' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N3).and_return 59
      end

      it { expect(restitution.niveau_numeratie).to eq 3 }
    end

    context 'quand le pourcentage de réussite pour N3 est supérieur à 70' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N3).and_return 71
        allow(restitution).to receive(:a_passe_des_questions_de_rattrapage?).and_return true
      end

      it { expect(restitution.niveau_numeratie).to eq 4 }
    end

    context 'quand le pourcentage de réussite pour N3 est supérieur à 70 sans rattrapage' do
      before do
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N1).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N2).and_return 71
        allow(restitution).to receive(:pourcentage_de_reussite_pour).with(:N3).and_return 71
        allow(restitution).to receive(:a_passe_des_questions_de_rattrapage?).and_return false
      end

      it { expect(restitution.niveau_numeratie).to eq 5 }
    end
  end

  describe '#a_passe_des_questions_de_rattrapage?' do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(described_class).to receive(
        :calcule_pourcentage_reussite_competence_clea
      )
      # rubocop:enable RSpec/AnyInstance
    end

    context 'sans rattrapage' do
      let(:restitution) do
        described_class.new(campagne,
                            [
                              build(:evenement_demarrage, partie: partie),
                              build(:evenement_reponse,
                                    donnees: { succes: true,
                                               question: 'N3Pse1',
                                               score: 1 },
                                    partie: partie),
                              build(:evenement_reponse,
                                    donnees: { succes: true,
                                               question: 'N3Pvn1',
                                               score: 1 },
                                    partie: partie),
                              build(:evenement_reponse,
                                    donnees: { succes: true,
                                               question: 'N3Prn1',
                                               score: 1 },
                                    partie: partie)
                            ])
      end

      it do
        expect(restitution.a_passe_des_questions_de_rattrapage?).to be false
      end
    end

    context 'avec du rattrapage' do
      let(:restitution) do
        described_class.new(campagne,
                            [
                              build(:evenement_demarrage, partie: partie),
                              build(:evenement_reponse, donnees: { succes: true,
                                                                   question: 'N3Pse1',
                                                                   score: 1 },
                                                        partie: partie),
                              build(:evenement_reponse, donnees: { succes: true,
                                                                   question: 'N3Pvn1',
                                                                   score: 1 },
                                                        partie: partie),
                              build(:evenement_reponse, donnees: { succes: true,
                                                                   question: 'N3Prn1',
                                                                   score: 1 },
                                                        partie: partie),
                              build(:evenement_reponse, donnees: { succes: true,
                                                                   question: 'N3Rrn1',
                                                                   score: 2 },
                                                        partie: partie)
                            ])
      end

      it do
        expect(restitution.a_passe_des_questions_de_rattrapage?).to be true
      end
    end
  end
end
