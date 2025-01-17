# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Positionnement::ExportNumeratie do
  subject(:response_service) do
    described_class.new(partie, onglet_xls)
  end

  let(:partie) { create :partie }
  let(:export) { ImportExport::ExportXls.new }
  let(:onglet_xls) do
    entetes = ImportExport::Positionnement::ExportDonnees.new(partie).entetes
    export.cree_worksheet_donnees(entetes)
  end
  let(:spreadsheet) { export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }

  describe '#regroupe_par_codes_clea' do
    it 'trie les evenements par codes clea' do
      evenement1 = create :evenement_reponse, partie: partie,
                                              donnees: { metacompetence: 'perimetres' }
      evenement2 = create :evenement_reponse, partie: partie,
                                              donnees: { metacompetence: 'estimation' }

      results = {
        '2.1' => {
          '2.1.4' => [evenement2.donnees]
        },
        '2.3' => {
          '2.3.7' => [evenement1.donnees]
        }
      }

      expect(response_service.regroupe_par_codes_clea).to eq(results)
    end

    describe 'quand il y a des questions non répondues' do
      let(:questions) do
        [
          create(:question_qcm, nom_technique: 'LOdi3', metacompetence: :surfaces),
          create(:question_qcm, nom_technique: 'LOdi2', metacompetence: :estimation),
          create(:question_qcm, nom_technique: 'LOdi4', metacompetence: :tableaux_graphiques)
        ]
      end

      let!(:evenements) do
        [
          create(:evenement_reponse, partie: partie,
                                     donnees: { question: 'LOdi1', metacompetence: :surfaces }),
          create(:evenement_reponse, partie: partie,
                                     donnees: { question: 'LOdi2', metacompetence: :estimation })
        ]
      end

      let(:liste) { response_service.regroupe_par_codes_clea }

      before do
        partie.situation.update(questionnaire: create(:questionnaire))
        partie.situation.questionnaire.questions.push(*questions)
      end

      it 'trie les evenements et les questions non répondues par code clea' do
        expect(liste['2.1']['2.1.4']).to eq([evenements[1].donnees])
        expect(liste['2.3']['2.3.7'][0]).to eq(evenements[0].donnees)
        expect(liste['2.3']['2.3.7'][1]['question']).to eq(questions[0].nom_technique)
        expect(liste['2.3']['2.3.7'][1]['scoreMax']).to eq(questions[0].score)
      end

      it "tri dans l'ordre croissant" do
        expect(liste.keys).to eq(['2.1', '2.3'])
        expect(liste['2.3'].keys).to eq(['2.3.5', '2.3.7'])
      end
    end
  end

  describe '#questions_non_repondues' do
    let!(:question_consigne) { create(:question_sous_consigne, nom_technique: 'N1Pse1') }
    let!(:question_rattrapage) { create(:question_qcm, nom_technique: 'N1Rse1') }
    let!(:question_deja_repondue) { create(:question_qcm, nom_technique: 'N2Poa1') }
    let!(:question_non_repondue) { create(:question_qcm, nom_technique: 'N2Poa2') }

    before do
      partie.situation.update(questionnaire: create(:questionnaire))
    end

    it 'renvoie les questions non répondues' do
      partie.situation.questionnaire.questions << question_non_repondue
      expect(response_service.questions_non_repondues).to eq([question_non_repondue])
    end

    it 'exclut les sous consignes' do
      partie.situation.questionnaire.questions << question_consigne
      expect(response_service.questions_non_repondues).to eq([])
    end

    it "n'exclut pas les questions de rattrapage" do
      partie.situation.questionnaire.questions << question_rattrapage
      expect(response_service.questions_non_repondues).to eq([question_rattrapage])
    end

    it 'exclut les questions déjà répondues' do
      partie.situation.questionnaire.questions << question_deja_repondue
      create :evenement_reponse,
             partie: partie,
             donnees: { question: 'N2Poa1' }
      expect(response_service.questions_non_repondues).to eq([])
    end
  end

  describe '#remplis_sous_domaine' do
    let(:ligne) { 1 }
    let(:code) { '2.1' }

    context "quand les questions de rattrapage n'ont pas été repondues" do
      let(:reponses) do
        [
          { 'question' => 'N1Poa1', 'score' => 1, 'scoreMax' => 2 },
          { 'question' => 'N1Roa1', 'score' => nil, 'scoreMax' => 2 }
        ]
      end

      it 'remplis les sous domaines' do
        response_service.remplis_sous_domaine(ligne, code, reponses)
        expect(worksheet[ligne, 0]).to eq('2.1')
        expect(worksheet[ligne, 1]).to eq("Se repérer dans l'univers des nombres")
        expect(worksheet[ligne, 2]).to eq(1)
        expect(worksheet[ligne, 3]).to eq(2)
        expect(worksheet[ligne, 4]).to eq(0.5)
      end
    end

    context 'quand les questions de rattrapge ont été repondues' do
      let(:reponses) do
        [
          { 'question' => 'N1Poa1', 'score' => 1, 'scoreMax' => 2 },
          { 'question' => 'N1Roa1', 'score' => 0, 'scoreMax' => 2 }
        ]
      end

      it 'remplis les sous domaines' do
        response_service.remplis_sous_domaine(ligne, code, reponses)
        expect(worksheet[ligne, 0]).to eq('2.1')
        expect(worksheet[ligne, 1]).to eq("Se repérer dans l'univers des nombres")
        expect(worksheet[ligne, 2]).to eq(1)
        expect(worksheet[ligne, 3]).to eq(4)
        expect(worksheet[ligne, 4]).to eq(0.25)
      end
    end
  end

  describe '#remplis_sous_sous_domaine' do
    let(:ligne) { 1 }
    let(:sous_code) { '2.1.1' }

    context "quand les questions de rattrapage n'ont pas été repondues" do
      let(:reponses) do
        [
          { 'question' => 'N1Poa1', 'score' => 1, 'scoreMax' => 2 },
          { 'question' => 'N1Roa1', 'score' => nil, 'scoreMax' => 2 }
        ]
      end

      it 'remplis les sous domaines' do
        response_service.remplis_sous_sous_domaine(ligne, sous_code, reponses)
        expect(worksheet[ligne, 0]).to eq('2.1.1')
        expect(worksheet[ligne,
                         1]).to eq('Réaliser les 4 opérations à la main ou avec une calculette')
        expect(worksheet[ligne, 2]).to eq(1)
        expect(worksheet[ligne, 3]).to eq(2)
        expect(worksheet[ligne, 4]).to eq(0.5)
      end
    end

    context 'quand les questions de rattrapge ont été repondues' do
      let(:reponses) do
        [
          { 'question' => 'N1Poa1', 'score' => 1, 'scoreMax' => 2 },
          { 'question' => 'N1Roa1', 'score' => 0, 'scoreMax' => 2 }
        ]
      end

      it 'remplis les sous domaines' do
        response_service.remplis_sous_sous_domaine(ligne, sous_code, reponses)
        expect(worksheet[ligne, 0]).to eq('2.1.1')
        expect(worksheet[ligne,
                         1]).to eq('Réaliser les 4 opérations à la main ou avec une calculette')
        expect(worksheet[ligne, 2]).to eq(1)
        expect(worksheet[ligne, 3]).to eq(4)
        expect(worksheet[ligne, 4]).to eq(0.25)
      end
    end
  end
end
