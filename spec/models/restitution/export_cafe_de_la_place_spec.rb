# frozen_string_literal: true

require 'rails_helper'

describe Restitution::ExportPositionnement do
  let(:situation) { create(:situation) }
  let(:evaluation) { create :evaluation }
  let(:question) { create(:question) }
  let!(:partie) { create :partie, evaluation: evaluation, situation: situation }

  subject(:response_service) do
    described_class.new(partie: partie)
  end

  describe '.to_xls' do
    it 'génére un fichier xls avec les entêtes sur chaque colonnes' do
      xls = response_service.to_xls
      spreadsheet = Spreadsheet.open(StringIO.new(xls))
      worksheet = spreadsheet.worksheet(0)

      expect(spreadsheet.worksheets.count).to eq(1)
      expect(worksheet.row(0)[0]).to eq('Code Question')
      expect(worksheet.row(0)[1]).to eq('Intitulé')
      expect(worksheet.row(0)[2]).to eq('Réponse')
      expect(worksheet.row(0)[3]).to eq('Score')
      expect(worksheet.row(0)[4]).to eq('Score max')
      expect(worksheet.row(0)[5]).to eq('Métacompétence')
    end

    it 'génére un fichier xls avec les evenements réponses' do
      create :evenement_reponse,
             partie: partie,
             donnees: {
               question: 'LOdi1',
               reponse: 'couverture',
               reponseIntitule: nil,
               score: 2,
               scoreMax: 2,
               intitule: 'De quoi s’agit-il ?',
               metacompetence: 'numeratie'
             }
      intitule_question2 = 'Donc, c’est une émission sur les livres. Quel est le nom du livre \
      dont on parle ?'
      create :evenement_reponse,
             partie: partie,
             donnees: {
               intitule: intitule_question2,
               question: 'LOdi4',
               reponse: 'chatMadameCoupin',
               reponseIntitule: 'Le chat de Mme Coupin'
             }

      xls = response_service.to_xls
      spreadsheet = Spreadsheet.open(StringIO.new(xls))
      worksheet = spreadsheet.worksheet(0)

      question1 = worksheet.row(1)
      expect(question1[0]).to eq('LOdi1')
      expect(question1[1]).to eq('De quoi s’agit-il ?')
      expect(question1[2]).to eq('couverture')
      expect(question1[3]).to eq(2)
      expect(question1[4]).to eq(2)
      expect(question1[5]).to eq('numeratie')

      question2 = worksheet.row(2)
      expect(question2[0]).to eq('LOdi4')
      expect(question2[1]).to eq(intitule_question2)
      expect(question2[2]).to eq('Le chat de Mme Coupin')
      expect(question2[3]).to eq(nil)
      expect(question2[4]).to eq(nil)
      expect(question2[5]).to eq(nil)
    end
  end
end
