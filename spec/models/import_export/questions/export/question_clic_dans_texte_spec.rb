# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Export::QuestionClicDansTexte do
  include_context 'export'

  let(:type) { 'QuestionClicDansTexte' }
  let(:question) do
    create(:question_clic_dans_image, metacompetence: 'operations_soustraction',
                                      description: 'Ceci est une description',
                                      nom_technique: 'clic',
                                      score: 2)
  end
  let!(:intitule) do
    create(:transcription, :avec_audio, question_id: question.id, categorie: :intitule,
                                        ecrit: 'Ceci est un intitulé')
  end
  let!(:consigne) do
    create(:transcription, :avec_audio, question_id: question.id,
                                        categorie: :modalite_reponse,
                                        ecrit: 'Ceci est une consigne')
  end

  it 'génére un fichier xls avec les entêtes sur chaque colonnes' do
    expect(spreadsheet.worksheets.count).to eq(1)

    headers_attendus = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[
      QuestionClicDansTexte::QUESTION_TYPE
    ]
    expect(headers_xls).to eq headers_attendus
  end

  it 'génére un fichier xls avec les détails de la question' do
    ligne = worksheet.row(1)
    expect(ligne[0]).to eq('Question clic dans image')
    expect(ligne[1]).to eq('clic')
    expect(ligne[2]).to eq(2)
    expect(ligne[3]).to be_nil
    expect(ligne[4]).to eq('Ceci est un intitulé')
    expect(ligne[5]).to eq(intitule.audio_url)
    expect(ligne[6]).to eq('operations_soustraction')
    expect(ligne[7]).to eq('Ceci est une consigne')
    expect(ligne[8]).to eq(consigne.audio_url)
    expect(ligne[9]).to eq('Ceci est une description')
    expect(ligne[10]).to be(false)
    expect(ligne[11]).to eq(question.texte_sur_illustration)
  end
end
