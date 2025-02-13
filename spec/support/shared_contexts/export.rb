# frozen_string_literal: true

shared_context 'export' do
  subject(:response_service) do
    response_service = described_class.new(
      [question], ImportExport::Questions::ImportExportDonnees::HEADERS_COMMUN
    )
    response_service.to_xls
    response_service
  end

  let(:headers) { [] }
  let(:question) { create(:question) }
  let(:spreadsheet) { response_service.export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }
  let(:headers_xls) { worksheet.row(0).map { |header| header.parameterize.underscore.to_sym } }
end
