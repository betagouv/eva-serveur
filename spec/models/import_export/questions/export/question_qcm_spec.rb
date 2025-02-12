# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Export::QuestionQcm do
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

  let(:question) { create(:question_qcm) }
  let(:headers) do
    ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
  end
  let!(:reponse) { create(:choix, :bon, question_id: question.id) }
  let!(:reponse2) { create(:choix, :mauvais, question_id: question.id) }

  it 'génére un fichier xls avec les entêtes spécifiques' do
    expect(spreadsheet.worksheets.count).to eq(1)

    headers_attendus = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[
      QuestionQcm::QUESTION_TYPE
    ]
    headers_attendus += %i[choix_1_intitule choix_1_nom_technique choix_1_type_choix
                           choix_1_audio_url choix_2_intitule choix_2_nom_technique
                           choix_2_type_choix choix_2_audio_url]

    expect(headers_xls).to eq headers_attendus
  end

  it 'génére un fichier xls avec les détails de la question' do
    ligne = worksheet.row(1)
    expect(ligne[8]).to eq(question.type_qcm)
    expect(ligne[9]).to eq(reponse.intitule)
    expect(ligne[10]).to eq(reponse.nom_technique)
    expect(ligne[11]).to eq(reponse.type_choix)
    expect(ligne[12]).to eq(reponse.audio_url)
    expect(ligne[13]).to eq(reponse2.intitule)
    expect(ligne[14]).to eq(reponse2.nom_technique)
    expect(ligne[15]).to eq(reponse2.type_choix)
    expect(ligne[16]).to eq(reponse2.audio_url)
  end
end
