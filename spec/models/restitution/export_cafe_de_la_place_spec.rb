# frozen_string_literal: true

require 'rails_helper'

describe Restitution::ExportCafeDeLaPlace do
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
      expect(worksheet.row(0)[1]).to eq('Réponse')
      expect(worksheet.row(0)[2]).to eq('Score')
    end

    it 'génére un fichier xls avec les evenements réponses' do
      create :evenement_reponse, donnees: { question: 'LOdi1', reponse: 'couverture', score: 2 },
                                 partie: partie
      create :evenement_reponse, donnees: { question: 'ACrd3', reponse: 'Londres' }, partie: partie

      xls = response_service.to_xls
      spreadsheet = Spreadsheet.open(StringIO.new(xls))
      worksheet = spreadsheet.worksheet(0)

      expect(worksheet.row(1)[0]).to eq('LOdi1')
      expect(worksheet.row(1)[1]).to eq('couverture')
      expect(worksheet.row(1)[2]).to eq(2)

      expect(worksheet.row(2)[0]).to eq('ACrd3')
      expect(worksheet.row(2)[1]).to eq('Londres')
      expect(worksheet.row(2)[2]).to eq(0)
    end
  end
end
