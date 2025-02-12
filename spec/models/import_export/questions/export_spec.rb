# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Export do
  subject(:response_service) do
    response_service = exporteur.new(
      [question], ImportExport::Questions::ImportExportDonnees::HEADERS_COMMUN
    )
    response_service.to_xls
    response_service
  end

  let(:exporteur) { described_class }
  let(:headers) { [] }
  let(:question) { create(:question) }
  let(:spreadsheet) { response_service.export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }
  let(:headers_xls) { worksheet.row(0).map { |header| header.parameterize.underscore.to_sym } }

  describe '#nom_du_fichier' do
    it 'genere le nom du fichier' do
      Timecop.freeze(Date.new(2025, 2, 28)) do
        nom_du_fichier_attendu = '20250228-QuestionQcm.xls'
        expect(response_service.nom_du_fichier('QuestionQcm')).to eq(nom_du_fichier_attendu)
      end
    end
  end

  describe '#content_type_xls' do
    it { expect(response_service.content_type_xls).to eq 'application/vnd.ms-excel' }
  end
end
