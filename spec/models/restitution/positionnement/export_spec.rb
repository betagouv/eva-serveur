# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Positionnement::Export do
  subject(:response_service) do
    described_class.new(partie: partie)
  end

  let(:spreadsheet) { Spreadsheet.open(StringIO.new(response_service.to_xls)) }
  let(:worksheet) { spreadsheet.worksheet(0) }
  let(:question) { create(:question_qcm, nom_technique: 'LOdi1') }
  let(:partie) { create :partie }

  describe 'pour un export littératie' do
    let(:situation) { create(:situation_cafe_de_la_place) }
    let!(:partie) { create :partie, situation: situation }

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

    describe 'génére un fichier xls avec les evenements réponses' do
      let(:intitule_question2) do
        'Donc, c’est une émission sur les livres. Quel est le nom du livre dont on parle ?'
      end

      before do
        create :evenement_affichage_question_qcm,
               date: DateTime.current,
               partie: partie,
               donnees: { question: 'LOdi1' }
        create :evenement_reponse,
               partie: partie,
               date: DateTime.current,
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

      it 'verifie les détails de la première question question' do
        ligne = worksheet.row(1)
        expect(ligne[0]).to eq('LOdi1')
        expect(ligne[1]).to eq('De quoi s’agit-il ?')
        expect(ligne[2]).to eq('couverture')
        expect(ligne[3]).to eq(2)
        expect(ligne[4]).to eq(2)
        expect(ligne[5]).to eq('lecture')
        expect(ligne[6]).to eq('00:00')
      end

      it 'verifie les détails de la deuxième question' do
        ligne = worksheet.row(2)
        expect(ligne[0]).to eq('LOdi2')
        expect(ligne[1]).to eq(intitule_question2)
        expect(ligne[2]).to eq('Le chat de Mme Coupin')
        expect(ligne[3]).to be_nil
        expect(ligne[4]).to be_nil
        expect(ligne[5]).to be_nil
        expect(ligne[6]).to eq('00:00')
      end
    end
  end

  describe 'pour un export numératie' do
    let(:situation) { create(:situation_place_du_marche) }
    let!(:partie) { create :partie, situation: situation }
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

    describe 'génére un fichier xls avec les evenements réponses' do
      before do
        create :evenement_reponse,
               date: DateTime.current,
               partie: partie,
               donnees: { question: 'LOdi1',
                          reponse: 'drapeau',
                          reponseIntitule: "c'est un drapeau",
                          score: 0,
                          scoreMax: 2,
                          intitule: 'De quoi s’agit-il ?',
                          metacompetence: :renseigner_horaires }
        create :evenement_affichage_question_qcm,
               date: DateTime.current,
               partie: partie,
               donnees: { question: 'LOdi1' }
        create :evenement_reponse,
               partie: partie,
               donnees: { question: 'LOdi2',
                          score: 1,
                          scoreMax: 2,
                          metacompetence: :renseigner_horaires }
        create :evenement_reponse,
               partie: partie,
               donnees: { question: 'LOdi3',
                          metacompetence: 'tableaux_graphiques',
                          scoreMax: 1,
                          score: 1 }
        partie.situation.update(questionnaire: create(:questionnaire))
        question = create(:question_qcm, nom_technique: 'LOdi4',
                                         metacompetence: :renseigner_horaires, score: 1)
        create :evenement_reponse,
               partie: partie,
               donnees: { question: 'LOdi5',
                          metacompetence: 'situation_dans_lespace' }
        partie.situation.questionnaire.questions << question
      end

      context "sur l'onglet de synthese" do
        it 'verifie la deuxième ligne avec le code cléa du sous domaine et le % de réussite' do
          worksheet = spreadsheet.worksheet(0)
          intitule = 'Lire et calculer les unités de mesures, de temps et des quantités'
          expect(worksheet.row(1)[0]).to eq('2.3')
          expect(worksheet.row(1)[1]).to eq(intitule)
          expect(worksheet.row(1)[2]).to eq(2)
          expect(worksheet.row(1)[3]).to eq(6.0)
          expect(worksheet.row(1)[4]).to eq('33%')
        end

        it 'verifie les sous sous domaines et le % de réussite dans un autre tableau' do
          worksheet = spreadsheet.worksheet(0)
          ligne = worksheet.row(4)
          expect(ligne[0]).to be_nil
          expect(ligne[1]).to be_nil
          expect(ligne[2]).to eq('Points')
          expect(ligne[3]).to eq('Points maximum')
          expect(ligne[4]).to eq('Score')

          ligne = worksheet.row(5)
          expect(ligne[0]).to eq('2.3.3')
          expect(ligne[1]).to eq('Renseigner correctement les horaires')
          expect(ligne[2]).to eq(1)
          expect(ligne[3]).to eq(5.0)
          expect(ligne[4]).to eq('20%')

          ligne = worksheet.row(6)
          expect(ligne[0]).to eq('2.3.5')
          expect(ligne[2]).to eq(1)
          expect(ligne[3]).to eq(1)
          expect(ligne[4]).to eq('100%')

          ligne = worksheet.row(7)
          expect(ligne[0]).to eq('2.5.3')
          expect(ligne[2]).to eq(0)
          expect(ligne[3]).to eq(0)
          expect(ligne[4]).to eq('non applicable')
        end
      end

      context "sur l'onglet de donnees" do
        it 'verifie les détails de la première question' do
          worksheet = spreadsheet.worksheet(1)
          ligne = worksheet.row(1)
          expect(ligne[0]).to eq('2.3.3')
          expect(ligne[1]).to eq('LOdi1')
          expect(ligne[2]).to eq('Renseigner horaires')
          expect(ligne[3]).to eq('0')
          expect(ligne[4]).to eq('2')
          expect(ligne[5]).to eq('qcm')
          expect(ligne[6]).to eq('De quoi s’agit-il ?')
          expect(ligne[7]).to eq('drapeau | couverture | autre')
          expect(ligne[8]).to eq('couverture')
          expect(ligne[9]).to eq("c'est un drapeau")
          expect(ligne[10]).to eq('00:59')
        end

        it 'verifie les questions du même sous sous domaine' do
          worksheet = spreadsheet.worksheet(1)
          ligne = worksheet.row(2)
          expect(ligne[0]).to eq('2.3.3')
          expect(ligne[1]).to eq('LOdi2')
          expect(ligne[10]).to eq('00:00')
          ligne = worksheet.row(3)
          expect(ligne[0]).to eq('2.3.3')
          expect(ligne[1]).to eq('LOdi4')
        end

        it 'verifie le sous sous domaine suivant' do
          worksheet = spreadsheet.worksheet(1)
          ligne = worksheet.row(5)
          expect(ligne[0]).to eq('2.5.3')
          expect(ligne[1]).to eq('LOdi5')
        end
      end
    end
  end

  describe '#nom_du_fichier' do
    it "genere le nom du fichier en fonction de l'évaluation" do
      code_de_campagne = partie.evaluation.campagne.code.parameterize
      nom_de_levaluation = partie.evaluation.nom.parameterize.first(15)
      date = DateTime.current.strftime('%Y%m%d')
      nom_du_fichier_attendu = "#{date}-#{nom_de_levaluation}-#{code_de_campagne}.xls"

      expect(response_service.nom_du_fichier).to eq(nom_du_fichier_attendu)
    end
  end
end
