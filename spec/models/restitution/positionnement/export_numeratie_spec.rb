# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Positionnement::ExportNumeratie do
  subject(:response_service) do
    described_class.new(partie, onglet_xls)
  end

  let(:question1) { create :question, nom_technique: 'N2Ppe1' }
  let(:question2) { create :question, nom_technique: 'N1Pes1' }
  let(:questions) { [ question1, question2 ] }
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
          create(:question_qcm, nom_technique: 'N2Psu1'),
          create(:question_qcm, nom_technique: 'N1Pes1'),
          create(:question_qcm, nom_technique: 'N2Ptg1')
        ]
      end

      let!(:evenements) do
        [
          create(:evenement_reponse, partie: partie,
                                     donnees: { question: 'N2Psu1' }),
          create(:evenement_reponse, partie: partie,
                                     donnees: { question: 'N1Pes1', metacompetence: :estimation })
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
        expect(liste.keys).to eq([ '2.1', '2.3' ])
        expect(liste['2.3'].keys).to eq([ '2.3.5', '2.3.7' ])
      end
    end

    describe '#tri_par_ordre_croissant' do
      it 'trie les questions correctement par code_clea et famille metacompetence' do
        question1 = create(:question, nom_technique: 'N1Poa1')
        question2 = create(:question, nom_technique: 'N1Poa2')
        question3 = create(:question, nom_technique: 'N1Roa1')
        question4 = create(:question, nom_technique: 'N1Roa2')
        question5 = create(:question, nom_technique: 'N1Pos1')
        question6 = create(:question, nom_technique: 'N1Pos2')
        question7 = create(:question, nom_technique: 'N1Ros1')
        question8 = create(:question, nom_technique: 'N1Ros2')

        evenements_questions = [
          EvenementQuestion.new(question: question1),
          EvenementQuestion.new(question: question2),
          EvenementQuestion.new(question: question3),
          EvenementQuestion.new(question: question4),
          EvenementQuestion.new(question: question5),
          EvenementQuestion.new(question: question6),
          EvenementQuestion.new(question: question7),
          EvenementQuestion.new(question: question8)
        ]

        groupes_clea = { '2.1.1' => evenements_questions }

        resultat = response_service.send(:tri_par_ordre_croissant, groupes_clea)

        expect(resultat['2.1.1'].map(&:nom_technique)).to eq(%w[
                                                               N1Poa1
                                                               N1Poa2
                                                               N1Roa1
                                                               N1Roa2
                                                               N1Pos1
                                                               N1Pos2
                                                               N1Ros1
                                                               N1Ros2
                                                             ])
      end
    end
  end
end
