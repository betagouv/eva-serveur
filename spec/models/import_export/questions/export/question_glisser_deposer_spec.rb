# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Export::QuestionGlisserDeposer do
  include_context 'export'

  let(:type) { 'QuestionGlisserDeposer' }
  let!(:question) { create(:question_glisser_deposer) }
  let!(:reponse) { create(:choix, :bon, question_id: question.id) }
  let!(:reponse2) { create(:choix, :mauvais, question_id: question.id) }

  it 'génére un fichier xls avec les entêtes spécifiques' do
    expect(spreadsheet.worksheets.count).to eq(1)

    headers_attendus = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[
      QuestionGlisserDeposer::QUESTION_TYPE
    ]
    headers_attendus += %i[reponse_1_nom_technique reponse_1_position_client reponse_1_type_choix
                           reponse_1_illustration_url reponse_2_nom_technique
                           reponse_2_position_client reponse_2_type_choix
                           reponse_2_illustration_url]

    expect(headers_xls).to eq headers_attendus
  end

  it 'génére un fichier xls avec les détails de la question' do
    ligne = worksheet.row(1)

    expect(ligne[8]).to eq(question.zone_depot_url)
    expect(ligne[9]).to eq(question.orientation)
    expect(ligne[10]).to eq(reponse.nom_technique)
    expect(ligne[11]).to eq(reponse.position_client.to_s)
    expect(ligne[12]).to eq(reponse.type_choix)
    expect(ligne[13]).to eq(reponse.illustration_url.to_s)
    expect(ligne[14]).to eq(reponse2.nom_technique)
    expect(ligne[15]).to eq(reponse2.position_client.to_s)
    expect(ligne[16]).to eq(reponse2.type_choix)
    expect(ligne[17]).to eq(reponse2.illustration_url.to_s)
  end
end
