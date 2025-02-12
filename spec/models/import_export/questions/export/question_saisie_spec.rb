# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Export::QuestionSaisie do
  subject(:response_service) do
    response_service = described_class.new(
      [question], ImportExport::Questions::ImportExportDonnees::HEADERS_COMMUN
    )
    response_service.to_xls
    response_service
  end

  let(:spreadsheet) { response_service.export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }
  let(:headers_xls) { worksheet.row(0).map { |header| header.parameterize.underscore.to_sym } }

  let(:question) { create(:question_saisie) }
  let(:headers) do
    ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
  end
  let!(:reponse) { create(:choix, :bon, question_id: question.id) }

  it 'génére un fichier xls avec les entêtes spécifiques' do
    expect(spreadsheet.worksheets.count).to eq(1)

    headers_attendus = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[
      QuestionSaisie::QUESTION_TYPE
    ]
    headers_attendus += %i[reponse_1_intitule reponse_1_nom_technique reponse_1_type_choix]

    expect(headers_xls).to eq headers_attendus
  end

  it 'génére un fichier xls avec les détails de la question' do
    ligne = worksheet.row(1)
    expect(ligne[8]).to eq(question.suffix_reponse)
    expect(ligne[9]).to eq(question.reponse_placeholder)
    expect(ligne[10]).to eq(question.type_saisie)
    expect(ligne[11]).to eq(question.texte_a_trous)
    expect(ligne[12]).to eq(question.reponses.last.intitule)
    expect(ligne[13]).to eq(question.reponses.last.nom_technique)
  end
end
