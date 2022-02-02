# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Evaluation', type: :feature do
  before { Bullet.enable = false }
  after { Bullet.enable = true }

  let(:mon_compte) { create :compte, role: role }
  let(:ma_campagne) do
    create :campagne, compte: mon_compte, libelle: 'Paris 2019', code: 'PARIS2019'
  end

  context 'Rôle admin' do
    let(:role) { 'admin' }
    before(:each) { connecte(mon_compte) }

    describe '#show' do
      # evaluation sans positionnement
      let!(:mon_evaluation) { create :evaluation, campagne: ma_campagne, created_at: 3.days.ago }
      let(:situation) { build(:situation_inventaire) }
      let!(:partie) { create :partie, situation: situation, evaluation: mon_evaluation }
      let!(:evenement) { create :evenement_demarrage, partie: partie }
      let(:restitution) { Restitution::Inventaire.new(ma_campagne, [evenement]) }

      # evaluation avec positionnement
      let(:bienvenue) { create(:situation_bienvenue, questionnaire: questionnaire) }
      let(:campagne_bienvenue) { create :campagne, compte: Compte.first }
      before { campagne_bienvenue.situations_configurations.create situation: bienvenue }
      let!(:mon_evaluation_bienvenue) { create :evaluation, campagne: campagne_bienvenue }
      let!(:partie_bienvenue) do
        create :partie, situation: bienvenue, evaluation: mon_evaluation_bienvenue
      end
      let!(:evenement_bienvenue) { create :evenement_demarrage, partie: partie_bienvenue }
      let(:questionnaire) { create :questionnaire, questions: [] }
      let(:restitution_bienvenue) do
        Restitution::Bienvenue.new(mon_evaluation_bienvenue, [evenement_bienvenue])
      end

      it 'sans auto_positionnement' do
        visit admin_evaluation_path(mon_evaluation)
        expect(page).to_not have_content 'auto-positionnement'
        expect(page).to have_content 'Roger'
      end

      it 'avec auto_positionnement' do
        visit admin_evaluation_path(mon_evaluation_bienvenue)
        expect(page).to have_content 'auto-positionnement'
        expect(page).to have_content 'Roger'
      end

      it "n'affiche pas les situations jouées" do
        visit admin_evaluation_path(mon_evaluation)
        expect(page).not_to have_content 'Selection Situation'
        expect(page).not_to have_content 'Inventaire'
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
          allow(restitution_globale).to receive(:synthese).and_return('synthese')
          allow(FabriqueRestitution).to receive(:restitution_globale)
            .and_return(restitution_globale)
        end

        describe 'affiche le niveau global de litteratie et numératie' do
          before do
            allow(restitution_globale).to receive(:interpretations_niveau2).and_return([])
          end

          it 'affiche deux niveaux différents pour litteratie et numératie CEFR' do
            allow(restitution_globale).to receive(:interpretations_niveau1_anlci).and_return([])
            allow(restitution_globale).to receive(:interpretations_niveau1_cefr)
              .and_return(
                [
                  { litteratie: :palier1 },
                  { numeratie: :palier1 }
                ]
              )
            visit admin_evaluation_path(mon_evaluation_bienvenue)
            expect(page).to have_xpath("//img[@alt='Niveau A1']")
            expect(page).to have_xpath("//img[@alt='Niveau X1']")
          end

          it 'affiche deux niveaux différents pour litteratie et numératie ANLCI' do
            allow(restitution_globale).to receive(:interpretations_niveau1_anlci)
              .and_return(
                [
                  { litteratie: :palier2 },
                  { numeratie: :palier3 }
                ]
              )
            allow(restitution_globale).to receive(:interpretations_niveau1_cefr).and_return([])
            visit admin_evaluation_path(mon_evaluation_bienvenue)
            expect(page).to have_xpath("//img[@alt='Niveau 3']")
            expect(page).to have_xpath("//img[@alt='Niveau 4']")
          end

          it "affiche que le score n'a pas pu être calculé" do
            allow(restitution_globale).to receive(:interpretations_niveau1_anlci).and_return([])
            allow(restitution_globale).to receive(:interpretations_niveau1_cefr)
              .and_return(
                [
                  { litteratie: nil },
                  { numeratie: nil }
                ]
              )
            visit admin_evaluation_path(mon_evaluation_bienvenue)
            expect(page).to have_content "Votre score n'a pas pu être calculé"
          end

          it "Socle cléa en cours d'acquisition" do
            allow(restitution_globale).to receive(:interpretations_niveau1_anlci).and_return([])
            allow(restitution_globale).to receive(:interpretations_niveau1_cefr)
              .and_return(
                [
                  { litteratie: :palier3 },
                  { numeratie: :palier3 }
                ]
              )
            allow(restitution_globale).to receive(:synthese).and_return('socle_clea')
            visit admin_evaluation_path(mon_evaluation_bienvenue)
            expect(page).to have_content 'Certification Cléa indiquée'
          end

          it "Potentiellement en situation d'illettrisme" do
            allow(restitution_globale).to receive(:interpretations_niveau1_anlci).and_return([])
            allow(restitution_globale).to receive(:interpretations_niveau1_cefr)
              .and_return(
                [
                  { litteratie: :palier1 },
                  { numeratie: :palier1 }
                ]
              )
            allow(restitution_globale).to receive(:synthese).and_return('illettrisme_potentiel')
            visit admin_evaluation_path(mon_evaluation_bienvenue)
            expect(page).to have_content 'Formation vivement recommandée'
          end
        end

        describe 'affiche le niveau des metacompétences' do
          before do
            allow(restitution_globale).to receive(:interpretations_niveau1_anlci).and_return([])
            allow(restitution_globale).to receive(:interpretations_niveau1_cefr).and_return([])
          end

          it 'de litteratie et numératie' do
            allow(restitution_globale).to receive(:interpretations_niveau2)
              .with(:litteratie)
              .and_return([{ score_ccf: :palier0 }])
            allow(restitution_globale).to receive(:interpretations_niveau2)
              .with(:numeratie)
              .and_return([{ score_numeratie: :palier0 }])
            visit admin_evaluation_path(mon_evaluation_bienvenue)

            expect(page).to have_content 'Connaissance et compréhension du français'
            expect(page).to have_content 'des progrès à faire'

            expect(page).to have_content 'Compétences mathématiques'
          end
        end

        it "affiche l'évaluation en pdf" do
          allow(restitution_globale).to receive(:interpretations_niveau1_anlci).and_return([])
          allow(restitution_globale).to receive(:interpretations_niveau1_cefr).and_return([])
          allow(restitution_globale).to receive(:interpretations_niveau2).and_return([])
          visit admin_evaluation_path(mon_evaluation, format: :pdf)
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
      before { visit admin_evaluation_path(evaluation) }

      it do
        expect do
          within('#action_items_sidebar_section') { click_on 'Supprimer' }
        end.to(change { Evaluation.count }
                                       .and(change { Evenement.count }))
        expect(page.current_url).to eql(admin_campagne_url(ma_campagne))
      end
    end
  end

  describe 'Edition' do
    let(:evaluation) { create :evaluation, campagne: ma_campagne, nom: 'Ancien nom' }
    let!(:campagne_autre_structure) { create :campagne, libelle: 'Campagne autre structure' }

    before { connecte(mon_compte) }

    context 'Superadmin' do
      let(:role) { 'superadmin' }

      before do
        visit edit_admin_evaluation_path(evaluation)
        fill_in :evaluation_nom, with: 'Nouveau Nom'
      end

      context 'en changeant de campagne' do
        it do
          within('#evaluation_campagne_input') { select 'Campagne autre structure' }
          click_on 'Modifier'
          expect(evaluation.reload.nom).to eq 'Nouveau Nom'
          expect(evaluation.campagne.libelle).to eq 'Campagne autre structure'
        end
      end

      context 'sans mettre de campagne' do
        it do
          within('#evaluation_campagne_input') { select '' }
          click_on 'Modifier'
          expect(evaluation.reload.nom).to eq 'Ancien nom'
        end
      end
    end

    context 'Admin' do
      let(:role) { 'admin' }
      let(:mon_collegue) { create :compte_admin, structure: mon_compte.structure }
      let!(:campagne_meme_structure) do
        create :campagne, compte: mon_collegue, libelle: 'Campagne même structure'
      end

      before { visit edit_admin_evaluation_path(evaluation) }

      it "me permet de modifier la campagne parmi celles auxquelles j'ai accès" do
        within('#evaluation_campagne_input') do
          expect(page).not_to have_content('Campagne autre structure')
          select 'Campagne même structure'
        end
        click_on 'Modifier'
        expect(evaluation.reload.campagne.libelle).to eq 'Campagne même structure'
      end
    end
  end
end
