# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Export::QuestionQcm do
  include_context 'export'

  let(:type) { 'QuestionQcm' }
  let(:question) { create(:question_qcm, metacompetence: 'operations_addition', score: 2) }
  let!(:reponse) { create(:choix, :bon, :avec_illustration, question_id: question.id) }
  let!(:reponse2) { create(:choix, :mauvais, :avec_illustration, question_id: question.id) }

  it 'génére un fichier xls avec les entêtes spécifiques' do
    expect(spreadsheet.worksheets.count).to eq(1)

    headers_attendus = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[
      QuestionQcm::QUESTION_TYPE
    ]
    headers_attendus += %i[choix_1_intitule choix_1_nom_technique choix_1_type_choix
                           choix_1_audio_url choix_1_illustration_url choix_2_intitule
                           choix_2_nom_technique choix_2_type_choix choix_2_audio_url
                           choix_2_illustration_url]

    expect(headers_xls).to eq headers_attendus
  end

  it 'génére un fichier xls avec les détails de la question' do
    ligne = worksheet.row(1)
    expect(ligne[2]).to eq(2)
    expect(ligne[10]).to be(false)
    expect(ligne[11]).to eq(question.type_qcm)
    expect(ligne[12]).to eq(reponse.intitule)
    expect(ligne[13]).to eq(reponse.nom_technique)
    expect(ligne[14]).to eq(reponse.type_choix)
    expect(ligne[15]).to eq(reponse.audio_url)
    expect(ligne[16]).to eq(reponse.illustration_url)
    expect(ligne[17]).to eq(reponse2.intitule)
    expect(ligne[18]).to eq(reponse2.nom_technique)
    expect(ligne[19]).to eq(reponse2.type_choix)
    expect(ligne[20]).to eq(reponse2.audio_url)
    expect(ligne[21]).to eq(reponse2.illustration_url)
  end
end
