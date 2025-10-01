require 'rails_helper'

describe ImportExport::Questionnaire::Export do
  subject(:response_service) do
    response_service = described_class.new(
      [ questionnaire ], headers
    )
    response_service.to_xls
    response_service
  end

  let(:headers) do
    ImportExport::Questionnaire::ImportExportDonnees::HEADERS_ATTENDUS
  end
  let(:question1) { create :question, nom_technique: 'question1' }
  let(:question2) { create :question, nom_technique: 'question2' }
  let(:question3) { create :question, nom_technique: 'question3' }
  let!(:questionnaire) { create(:questionnaire, questions: [ question1, question3, question2 ]) }
  let(:spreadsheet) { response_service.export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }
  let(:headers_xls) { worksheet.row(0).map { |header| header.parameterize.underscore.to_sym } }

  it 'génére un fichier xls avec les entêtes spécifiques' do
    expect(spreadsheet.worksheets.count).to eq(1)

    expect(headers_xls).to eq headers
  end

  it 'génére un fichier xls avec les détails de la question' do
    ligne = worksheet.row(1)

    expect(ligne[0]).to eq questionnaire.libelle
    expect(ligne[1]).to eq questionnaire.nom_technique
    expect(ligne[2]).to eq 'question1,question3,question2'
  end
end
