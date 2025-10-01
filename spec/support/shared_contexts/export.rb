shared_context 'export' do
  subject(:response_service) do
    response_service = described_class.new(
      [ question ], ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type]
    )
    response_service.to_xls
    response_service
  end

  let(:headers) do
    ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type]
  end

  let(:spreadsheet) { response_service.export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }
  let(:headers_xls) { worksheet.row(0).map { |header| header.parameterize.underscore.to_sym } }
end
