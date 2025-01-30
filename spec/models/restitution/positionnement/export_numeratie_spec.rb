# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Positionnement::ExportNumeratie do
  subject(:response_service) do
    described_class.new(partie, onglet_xls)
  end

  let(:question1) { create :question, nom_technique: 'N1Pde' }
  let(:question2) { create :question, nom_technique: 'N1Pes' }
  let(:questions) { [question1, question2] }
  let(:questionnaire) { create :questionnaire, questions: questions }
  let(:situation) { create :situation, questionnaire: questionnaire }
  let(:partie) { create :partie, situation: situation }
  let(:export) { ImportExport::ExportXls.new }
  let(:onglet_xls) do
    entetes = ImportExport::Positionnement::ExportDonnees.new(partie).entetes
    export.cree_worksheet_donnees(entetes)
  end
  let(:spreadsheet) { export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }

  describe '#regroupe_par_codes_clea' do
    it 'trie les evenements par codes clea' do
      create :evenement_reponse, partie: partie,
                                 donnees: {
                                   metacompetence: 'perimetres',
                                   question: question1.nom_technique
                                 }
      create :evenement_reponse, partie: partie,
                                 donnees: {
                                   metacompetence: 'estimation', question: question2.nom_technique
                                 }

      resultat = response_service.regroupe_par_codes_clea

      expect(resultat['2.1']['2.1.4'].first).to be_a EvenementQuestion
      expect(resultat['2.3']['2.3.7'].first).to be_a EvenementQuestion
    end

    describe 'quand il y a des questions non répondues' do
      let(:questions) do
        [
          create(:question_qcm, nom_technique: 'LOdi1', metacompetence: :surfaces),
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

      it 'trie les evenements et les questions non répondues par code clea' do
        question_non_repondue = questions[2]

        expect(liste['2.1']['2.1.4'][0].nom_technique).to eq(evenements[1].question_nom_technique)
        expect(liste['2.3']['2.3.7'][0].nom_technique).to eq(evenements[0].question_nom_technique)
        expect(liste['2.3']['2.3.5'][0].nom_technique).to eq(question_non_repondue.nom_technique)
        expect(liste['2.3']['2.3.5'][0].score_max).to eq(question_non_repondue.score)
      end

      it "tri dans l'ordre croissant" do
        expect(liste.keys).to eq(['2.1', '2.3'])
        expect(liste['2.3'].keys).to eq(['2.3.5', '2.3.7'])
      end
    end
  end
end
