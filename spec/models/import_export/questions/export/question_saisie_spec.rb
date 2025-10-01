require 'rails_helper'

describe ImportExport::Questions::Export::QuestionSaisie do
  include_context 'export'

  let(:type) { 'QuestionSaisie' }
  let(:question) { create(:question_saisie) }
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
    expect(ligne[8]).to be(false)
    expect(ligne[9]).to eq(question.suffix_reponse)
    expect(ligne[10]).to eq(question.reponse_placeholder)
    expect(ligne[11]).to eq(question.type_saisie)
    expect(ligne[12]).to eq(question.texte_a_trous)
    expect(ligne[13]).to eq(question.aide)
    expect(ligne[14]).to eq(question.reponses.last.intitule)
    expect(ligne[15]).to eq(question.reponses.last.nom_technique)
    expect(ligne[16]).to eq(question.reponses.last.type_choix)
  end
end
