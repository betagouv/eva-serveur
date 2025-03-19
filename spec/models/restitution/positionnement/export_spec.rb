# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Positionnement::Export do
  subject(:response_service) do
    response_service = described_class.new(partie: partie)
    response_service.to_xls
    response_service
  end

  let(:spreadsheet) { response_service.export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }
  let!(:question1) { create :question_qcm, nom_technique: 'LOdi1' }
  let!(:question2) { create :question_qcm, nom_technique: 'LOdi2' }
  let(:questions) { [question1, question2] }
  let(:questionnaire) { create :questionnaire, questions: questions }
  let(:campagne) { create :campagne, code: 'CODE123' }
  let(:evaluation) { create :evaluation, campagne: campagne }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }

  before do
    campagne.situations_configurations.create situation: situation, questionnaire: questionnaire
  end

  describe 'pour un export littératie' do
    let(:situation) { create(:situation_cafe_de_la_place) }
    let(:intitule_question2) do
      'Donc, c’est une émission sur les livres. Quel est le nom du livre dont on parle ?'
    end

    before do
      heure_debut = DateTime.new(2025, 1, 17, 10, 0, 0)
      heure_fin = heure_debut + 59.seconds
      create :evenement_affichage_question_qcm,
             partie: partie,
             date: heure_debut,
             donnees: { question: 'LOdi1' }
      create :evenement_reponse,
             partie: partie,
             date: heure_fin,
             donnees: { question: 'LOdi1',
                        reponse: 'couverture',
                        score: 2,
                        scoreMax: 2,
                        intitule: 'De quoi s’agit-il ?',
                        metacompetence: 'lecture' }
      create :evenement_reponse,
             partie: partie,
             donnees: { intitule: intitule_question2,
                        question: 'LOdi2',
                        reponseIntitule: 'Le chat de Mme Coupin' }
    end

    describe 'génére un fichier xls avec les evenements réponses' do
      it 'génére un fichier xls avec les entêtes sur chaque colonnes' do
        expect(spreadsheet.worksheets.count).to eq(1)
        expect(worksheet.row(0)[0]).to eq('Code Question')
        expect(worksheet.row(0)[1]).to eq('Intitulé')
        expect(worksheet.row(0)[2]).to eq('Réponse')
        expect(worksheet.row(0)[3]).to eq('Score')
        expect(worksheet.row(0)[4]).to eq('Score max')
        expect(worksheet.row(0)[5]).to eq('Métacompétence')
        expect(worksheet.row(0)[6]).to eq('Temps de passation')
      end

      it 'verifie les détails de la première question question' do
        ligne = worksheet.row(1)

        expect(ligne[0]).to eq('LOdi1')
        expect(ligne[1]).to eq('De quoi s’agit-il ?')
        expect(ligne[2]).to eq('couverture')
        expect(ligne[3]).to eq(2)
        expect(ligne[4]).to eq(2)
        expect(ligne[5]).to eq('lecture')
        expect(ligne[6]).to eq('00:59')
      end

      it 'verifie les détails de la deuxième question' do
        ligne = worksheet.row(2)
        expect(ligne[0]).to eq('LOdi2')
        expect(ligne[1]).to eq(intitule_question2)
        expect(ligne[2]).to eq('Le chat de Mme Coupin')
        expect(ligne[3]).to eq 0
        expect(ligne[4]).to be_nil
        expect(ligne[5]).to be_nil
        expect(ligne[6]).to be_nil
      end
    end
  end

  describe 'pour un export numératie' do
    let!(:question) { create :question }
    let(:questions) { [question] }
    let!(:situation) { create(:situation_place_du_marche) }
    let!(:choix) { create(:choix, :mauvais, question_id: question.id, intitule: 'drapeau') }
    let!(:choix2) { create(:choix, :bon, question_id: question.id, intitule: 'couverture') }
    let!(:choix3) { create(:choix, :mauvais, question_id: question.id, intitule: 'autre') }

    context 'génére un fichier xls avec les differents onglets' do
      it "vérifie les entetes de l'onglet synthèse" do
        worksheet = spreadsheet.worksheet(0)
        expect(worksheet.row(0)[2]).to eq('Points')
        expect(worksheet.row(0)[3]).to eq('Points maximum')
        expect(worksheet.row(0)[4]).to eq('Score')
      end

      it "vérifie les entetes de l'onglet donnees" do
        worksheet = spreadsheet.worksheet(1)
        expect(worksheet.row(0)[0]).to eq('Code cléa')
        expect(worksheet.row(0)[1]).to eq('Item')
        expect(worksheet.row(0)[2]).to eq('Méta compétence')
        expect(worksheet.row(0)[3]).to eq('Score attribué')
        expect(worksheet.row(0)[4]).to eq('Score possible de la question')
        expect(worksheet.row(0)[5]).to eq('Prise en compte dans le calcul du score Cléa ?')
        expect(worksheet.row(0)[6]).to eq('Interaction')
        expect(worksheet.row(0)[7]).to eq('Intitulé de la question')
        expect(worksheet.row(0)[8]).to eq('Réponses possibles')
        expect(worksheet.row(0)[9]).to eq('Réponses attendue')
        expect(worksheet.row(0)[10]).to eq('Réponse du bénéficiaire')
        expect(worksheet.row(0)[11]).to eq('Temps de passation')
      end
    end

    describe 'génére un fichier xls avec une question sans réponse' do
      let!(:question1) { create :question, :numeratie_niveau1 }
      let!(:question2) { create :question, :numeratie_niveau2 }
      let!(:question3) { create :question, :numeratie_niveau3 }
      let(:questions) { [question1, question2, question3] }

      before do
        heure_debut = DateTime.new(2025, 1, 17, 10, 0, 0)
        create :evenement_affichage_question_qcm,
               date: heure_debut,
               partie: partie,
               position: 1,
               donnees: { question: question1.nom_technique }
      end

      context "sur l'onglet de synthese" do
        it 'verifie la deuxième ligne avec le code cléa du sous domaine et le % de réussite' do
          worksheet = spreadsheet.worksheet(0)
          expect(worksheet.row(1)[0]).to be_nil
          expect(worksheet.row(1)[1]).to be_nil
          expect(worksheet.row(1)[2]).to eq(0)
          expect(worksheet.row(1)[3]).to eq(0)
          expect(worksheet.row(1)[4]).to eq('non applicable')
        end
      end
    end

    describe 'génére un fichier xls avec les evenements réponses' do
      let!(:question1) { create :question, :numeratie_niveau1 }
      let!(:question2) { create :question, :numeratie_niveau2 }
      let!(:question3) { create :question, :numeratie_niveau3 }
      let(:questions) { [question1, question2, question3] }

      before do
        heure_debut = DateTime.new(2025, 1, 17, 10, 0, 0)
        heure_fin = heure_debut + 59.seconds

        create :evenement_reponse,
               date: heure_fin,
               partie: partie,
               position: 2,
               donnees: { question: question1.nom_technique,
                          score: 0,
                          scoreMax: 2,
                          intitule: 'De quoi s’agit-il ?',
                          metacompetence: :renseigner_horaires }
        create :evenement_affichage_question_qcm,
               date: heure_debut,
               partie: partie,
               position: 1,
               donnees: { question: question1.nom_technique }
        create :evenement_reponse,
               partie: partie,
               position: 3,
               donnees: { question: question2.nom_technique,
                          score: 1,
                          scoreMax: 2,
                          metacompetence: :renseigner_horaires }
        create :evenement_reponse,
               position: 4,
               partie: partie,
               donnees: { question: question3.nom_technique,
                          metacompetence: 'tableaux_graphiques',
                          scoreMax: 2,
                          score: 1 }
      end

      context "sur l'onglet de synthese" do
        it 'verifie la deuxième ligne avec le code cléa du sous domaine et le % de réussite' do
          worksheet = spreadsheet.worksheet(0)
          intitule = 'Lire et calculer les unités de mesures, de temps et des quantités'
          expect(worksheet.row(1)[0]).to eq('2.3')
          expect(worksheet.row(1)[1]).to eq(intitule)
          expect(worksheet.row(1)[2]).to eq(2)
          expect(worksheet.row(1)[3]).to eq(6.0)
          expect(worksheet.row(1)[4]).to eq(0.33)
        end

        it 'verifie les sous sous domaines et le % de réussite dans un autre tableau' do
          worksheet = spreadsheet.worksheet(0)
          ligne = worksheet.row(4)
          expect(ligne[0]).to eq '2.3.3'
          expect(ligne[1]).to eq 'Renseigner correctement les horaires'
          expect(ligne[2]).to eq(1)
          expect(ligne[3]).to eq(4.0)
          expect(ligne[4]).to eq(0.25)

          ligne = worksheet.row(5)
          expect(ligne[0]).to eq('2.3.5')
          expect(ligne[2]).to eq(1)
          expect(ligne[3]).to eq(2)
          expect(ligne[4]).to eq(0.5)
        end
      end

      context "sur l'onglet de donnees" do
        it 'verifie les détails de la première question' do
          worksheet = spreadsheet.worksheet(ImportExport::ExportXls::WORKSHEET_DONNEES)
          ligne = worksheet.row(1)
          expect(ligne[0]).to eq('2.3.3')
          expect(ligne[1]).to eq(question1.nom_technique)
          expect(ligne[2]).to eq('Renseigner horaires')
          expect(ligne[3]).to eq(0)
          expect(ligne[4]).to eq(2)
          expect(ligne[5]).to eq('Oui')
          expect(ligne[7]).to eq('De quoi s’agit-il ?')
          expect(ligne[11]).to eq('00:59')
        end

        it 'verifie les questions du même sous sous domaine' do
          worksheet = spreadsheet.worksheet(1)
          ligne = worksheet.row(2)
          expect(ligne[0]).to eq('2.3.3')
          expect(ligne[1]).to eq(question2.nom_technique)
          expect(ligne[10]).to be_nil
          ligne = worksheet.row(3)
          expect(ligne[0]).to eq('2.3.5')
          expect(ligne[1]).to eq(question3.nom_technique)
        end
      end
    end
  end

  describe '#nom_du_fichier' do
    let(:situation) { create :situation }

    it "genere le nom du fichier en fonction de l'évaluation" do
      Timecop.freeze(Time.zone.local(2025, 2, 28, 1, 2, 3)) do
        expect(response_service.nom_du_fichier).to eq('20250228010203-roger-code123.xls')
      end
    end
  end
end
