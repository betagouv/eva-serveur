require 'rails_helper'

describe Restitution::CafeDeLaPlace do
  let(:evaluation) { create :evaluation }
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
                                partie: partie),
                          build(:evenement_reponse,
                                donnees: { succes: true,
                                           question: 'HPar1',
                                           score: 1 },
                                partie: partie)
                        ])
  end

  describe '#parcours_bas' do
    it 'quand le profil lecture est le plus petit' do
      expect(restitution).to receive(:competences_litteratie)
        .and_return({
                      lecture: Restitution::SousCompetence::Litteratie.new(profil: :profil1),
                      comprehension: Restitution::SousCompetence::Litteratie.new(profil: :profil2),
                      production: Restitution::SousCompetence::Litteratie.new(profil: :profil3)
                    })

      expect(restitution.parcours_bas).to equal(:profil1)
    end

    it 'quand le profil comprehension est le plus petit' do
      expect(restitution).to receive(:competences_litteratie)
        .and_return({
                      lecture: Restitution::SousCompetence::Litteratie.new(profil: :profil3),
                      comprehension: Restitution::SousCompetence::Litteratie.new(profil: :profil2),
                      production: Restitution::SousCompetence::Litteratie.new(profil: :profil4)
                    })

      expect(restitution.parcours_bas).to equal(:profil2)
    end

    it "quand un profil n'est pas défini" do
      niveau_inter = Competence::NIVEAU_INDETERMINE
      expect(restitution).to receive(:competences_litteratie)
        .and_return({
                      lecture: Restitution::SousCompetence::Litteratie.new(profil: niveau_inter),
                      comprehension: Restitution::SousCompetence::Litteratie.new(profil: :profil2),
                      production: Restitution::SousCompetence::Litteratie.new(profil: :profil4)
                    })

      expect(restitution.parcours_bas).to equal(niveau_inter)
    end
  end

  describe '#parcours_haut' do
    context 'quand le score total est < 16 points' do
      it 'retourne le profil aberrant' do
        expect(restitution).to receive(:scores_parcours_haut)
          .and_return({ hpar: 3, hgac: 3, hcvf: 3, hpfb: 3 })
        expect(restitution.parcours_haut).to equal(Competence::PROFIL_ABERRANT)
      end
    end

    context 'quand le score total est >= 16 et < 26' do
      it 'retourne le profil 4H' do
        expect(restitution).to receive(:scores_parcours_haut)
          .and_return({ hpar: 4, hgac: 4, hcvf: 4, hpfb: 4 })
        expect(restitution.parcours_haut).to equal(Competence::PROFIL_4H)
      end
    end

    context 'quand le score total est >= 26 et < 33' do
      it 'retourne le profil 4H+' do
        expect(restitution).to receive(:scores_parcours_haut)
          .and_return({ hpar: 7, hgac: 7, hcvf: 7, hpfb: 7 })
        expect(restitution.parcours_haut).to equal(Competence::PROFIL_4H_PLUS)
      end
    end

    context 'quand le score total est >= 33' do
      it 'retourne le profil 4H++' do
        expect(restitution).to receive(:scores_parcours_haut)
          .and_return({ hpar: 9, hgac: 9, hcvf: 9, hpfb: 9 })
        expect(restitution.parcours_haut).to equal(Competence::PROFIL_4H_PLUS_PLUS)
      end
    end

    context "quand un des scores n'est pas défini" do
      it 'retourne le profil indeterminé' do
        expect(restitution).to receive(:scores_parcours_haut)
          .and_return({ hpar: nil, hgac: 9, hcvf: 5, hpfb: 2 })
        expect(restitution.parcours_haut).to equal(Competence::NIVEAU_INDETERMINE)
      end
    end
  end

  describe '#niveau_litteratie' do
    context 'quand un parcours haut est profil 4H++' do
      before do
        allow(restitution).to receive(:parcours_haut).and_return Competence::PROFIL_4H_PLUS_PLUS
      end

      it 'retourne le profil 4H++' do
        expect(restitution.niveau_litteratie).to equal(Competence::PROFIL_4H_PLUS_PLUS)
      end
    end

    context 'quand un parcours haut est indeterminé' do
      before do
        allow(restitution).to receive_messages(parcours_haut: Competence::NIVEAU_INDETERMINE,
                                               parcours_bas: Competence::PROFIL_3)
      end

      it 'retourne le profil du parcours bas' do
        expect(restitution.niveau_litteratie).to equal(Competence::PROFIL_3)
      end
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
