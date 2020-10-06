# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Evaluation', type: :feature do
  before(:each) { se_connecter_comme_organisation }

  let(:ma_campagne) do
    create :campagne, compte: Compte.first, libelle: 'Paris 2019', code: 'paris2019'
  end

  describe '#show' do
    # evaluation sans positionnement
    let!(:mon_evaluation) { create :evaluation, campagne: ma_campagne, created_at: 3.days.ago }
    let(:situation) { build(:situation_inventaire) }
    let!(:partie) { create :partie, situation: situation, evaluation: mon_evaluation }
    let!(:evenement) { create :evenement_demarrage, partie: partie }
    let(:restitution) { Restitution::Inventaire.new(ma_campagne, [evenement]) }

    # evaluation avec positionnement
    let!(:mon_evaluation_bienvenue) { create :evaluation, campagne: ma_campagne }
    let(:bienvenue) { build(:situation_bienvenue, questionnaire: questionnaire) }
    let!(:partie_bienvenue) do
      create :partie, situation: bienvenue, evaluation: mon_evaluation_bienvenue
    end
    let!(:evenement_bienvenue) { create :evenement_demarrage, partie: partie_bienvenue }
    let(:questionnaire) { create :questionnaire, questions: [] }
    let(:restitution_bienvenue) do
      Restitution::Bienvenue.new(mon_evaluation_bienvenue, [evenement_bienvenue])
    end

    it 'sans auto_positionnement' do
      visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation)
      expect(page).to_not have_content 'auto-positionnement'
      expect(page).to have_content 'Roger'
    end

    it 'avec auto_positionnement' do
      visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)
      expect(page).to have_content 'auto-positionnement'
      expect(page).to have_content 'Roger'
    end

    describe 'en moquant restitution_globale :' do
      let(:restitution_globale) do
        double(Restitution::Globale,
               date: DateTime.now,
               utilisateur: 'Roger',
               efficience: 5,
               restitutions: [restitution])
      end

      before do
        competences = [[Competence::ORGANISATION_METHODE, Competence::NIVEAU_4]]
        allow(restitution_globale).to receive(:niveaux_competences).and_return(competences)
        interpretations = [[Competence::ORGANISATION_METHODE, 4.0]]
        allow(restitution_globale).to receive(:interpretations_competences_transversales)
          .and_return(interpretations)
        allow(restitution_globale).to receive(:structure).and_return('structure')
        allow(FabriqueRestitution).to receive(:restitution_globale).and_return(restitution_globale)
      end

      describe 'affiche le niveau global de litteratie et numératie' do
        before do
          allow(restitution_globale).to receive(:interpretations_niveau2).and_return([])
        end

        it 'affiche deux niveaux different pour litteratie et numératie' do
          allow(restitution_globale).to receive(:interpretations_niveau1)
            .and_return([{ litteratie: :palier1 }, { numeratie: :palier1 }])
          visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)
          expect(page).to have_xpath("//img[@alt='Niveau A1']")
          expect(page).to have_xpath("//img[@alt='Niveau X1']")
        end

        it "affiche que le score n'a pas pu être calculé" do
          allow(restitution_globale).to receive(:interpretations_niveau1)
            .and_return([{ litteratie: nil }, { numeratie: nil }])
          visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)
          expect(page).to have_content "Votre score n'a pas pu être calculé"
        end

        it "Socle cléa en cours d'acquisition" do
          allow(restitution_globale).to receive(:interpretations_niveau1)
            .and_return(['socle_clea'])
          visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)
          expect(page).to have_content 'Vous avez atteint le niveau'
        end

        it "Potentiellement en situation d'illettrisme" do
          allow(restitution_globale).to receive(:interpretations_niveau1)
            .and_return(['illettrisme_potentiel'])
          visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)
          expect(page).to have_content 'importantes difficultés'
        end
      end

      describe 'affiche le niveau des metacompétences' do
        before do
          allow(restitution_globale).to receive(:interpretations_niveau1).and_return([])
        end

        it 'de litteratie et numératie' do
          allow(restitution_globale).to receive(:interpretations_niveau2)
            .with(:litteratie)
            .and_return([{ score_ccf: :palier1 }])
          allow(restitution_globale).to receive(:interpretations_niveau2)
            .with(:numeratie)
            .and_return([{ score_numeratie: :palier1 }])
          visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)

          expect(page).to have_content 'Connaissance et compréhension du français'
          expect(page).to have_content 'des progrès à faire'

          expect(page).to have_content 'Compétences mathématiques'
        end
      end

      it "affiche l'évaluation en pdf" do
        allow(restitution_globale).to receive(:interpretations_niveau1).and_return([])
        allow(restitution_globale).to receive(:interpretations_niveau2).and_return([])
        visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation, format: :pdf)
        path = page.save_page

        reader = PDF::Reader.new(path)
        expect(reader.page(1).text).to include('Roger')
        expect(reader.page(1).text).to include('structure')
      end
    end
  end

  describe 'suppression' do
    let(:evaluation) { create :evaluation, campagne: ma_campagne }
    let(:situation) { create :situation_tri }
    let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
    let!(:evenement) { create :evenement, partie: partie }
    before { visit admin_campagne_evaluation_path(ma_campagne, evaluation) }

    it do
      expect { click_on 'Supprimer' }.to(change { Evaluation.count }
                                     .and(change { Evenement.count }))
      expect(page.current_url).to eql(admin_campagne_url(ma_campagne))
    end
  end
end
