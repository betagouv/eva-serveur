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
    let(:restitution) do
      described_class.new(campagne, [
                            build(:evenement_demarrage, partie: partie),
                            build(:evenement_fin_situation, partie: partie)
                          ])
    end

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

  describe '#competences_litteratie' do
    let(:restitution) do
      described_class.new(campagne, [
                            build(:evenement_demarrage, partie: partie),
                            *evenements_avant_abandon,
                            build(:evenement_abandon, partie: partie)
                          ])
    end

    before do
      partie.update(metriques: { 'score_lecture' => 8,
                                 'score_comprehension' => 0,
                                 'score_production' => 0 })
    end

    context 'quand le bloc lecture est terminé avant un abandon' do
      let(:evenements_avant_abandon) do
        [ build(:evenement_reponse, partie: partie,
                                    donnees: { question: 'ALrd14', metacompetence: 'lecture',
                                               score: 1 }) ]
      end

      it 'attribue le profil de lecture et laisse les autres indéterminés' do
        profils = restitution.competences_litteratie.transform_values { |c| c.profil.to_sym }
        expect(profils).to eq(lecture: Competence::PROFIL_2,
                              comprehension: Competence::NIVEAU_INDETERMINE,
                              production: Competence::NIVEAU_INDETERMINE)
      end
    end

    context "quand le bloc lecture n'est pas terminé avant un abandon" do
      let(:evenements_avant_abandon) do
        [ build(:evenement_reponse, partie: partie,
                                    donnees: { question: 'ALrd13', metacompetence: 'lecture',
                                               score: 1 }) ]
      end

      it 'laisse le profil de lecture indéterminé' do
        expect(restitution.competences_litteratie[:lecture].profil.to_sym)
          .to eq(Competence::NIVEAU_INDETERMINE)
      end
    end

    context 'quand un seul item de production a une réponse avant un abandon' do
      let(:evenements_avant_abandon) do
        [ build(:evenement_reponse, partie: partie,
                                    donnees: { question: 'APlc1', metacompetence: 'production',
                                               score: 0 }) ]
      end

      it 'attribue le profil de production' do
        expect(restitution.competences_litteratie[:production].profil.to_sym)
          .to eq(Competence::PROFIL_1)
      end
    end

    context 'quand la partie est interrompue sans abandon après le bloc lecture' do
      let(:restitution) do
        described_class.new(campagne, [
                              build(:evenement_demarrage, partie: partie),
                              build(:evenement_reponse, partie: partie,
                                                        donnees: { question: 'ALrd14',
                                                                   metacompetence: 'lecture',
                                                                   score: 1 })
                            ])
      end

      it 'attribue le profil de lecture et laisse les autres indéterminés' do
        profils = restitution.competences_litteratie.transform_values { |c| c.profil.to_sym }
        expect(profils).to eq(lecture: Competence::PROFIL_2,
                              comprehension: Competence::NIVEAU_INDETERMINE,
                              production: Competence::NIVEAU_INDETERMINE)
      end
    end

    context 'quand la partie est terminée' do
      let(:restitution) do
        described_class.new(campagne, [
                              build(:evenement_demarrage, partie: partie),
                              build(:evenement_fin_situation, partie: partie)
                            ])
      end

      it 'attribue tous les profils' do
        profils = restitution.competences_litteratie.transform_values { |c| c.profil.to_sym }
        expect(profils).to eq(lecture: Competence::PROFIL_2,
                              comprehension: Competence::PROFIL_1,
                              production: Competence::PROFIL_1)
      end
    end
  end

  describe '#parcours_haut quand la partie est interrompue' do
    let(:restitution) do
      described_class.new(campagne, [
                            build(:evenement_demarrage, partie: partie),
                            build(:evenement_reponse, partie: partie,
                                                      donnees: { question: derniere_question,
                                                                 score: 1 }),
                            *evenements_de_fin
                          ])
    end

    before do
      allow(restitution).to receive(:scores_parcours_haut)
        .and_return({ hpar: 9, hgac: 9, hcvf: 9, hpfb: 9 })
    end

    context 'par un abandon avant le premier item HPfb' do
      let(:derniere_question) { 'HCvf4' }
      let(:evenements_de_fin) { [ build(:evenement_abandon, partie: partie) ] }

      it 'retourne le profil indeterminé' do
        expect(restitution.parcours_haut).to equal(Competence::NIVEAU_INDETERMINE)
      end
    end

    context 'sans abandon avant le premier item HPfb' do
      let(:derniere_question) { 'HCvf4' }
      let(:evenements_de_fin) { [] }

      it 'retourne le profil indeterminé' do
        expect(restitution.parcours_haut).to equal(Competence::NIVEAU_INDETERMINE)
      end
    end

    context 'par un abandon après un seul item HPfb' do
      let(:derniere_question) { 'HPfb1' }
      let(:evenements_de_fin) { [ build(:evenement_abandon, partie: partie) ] }

      it 'calcule le profil' do
        expect(restitution.parcours_haut).to equal(Competence::PROFIL_4H_PLUS_PLUS)
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
