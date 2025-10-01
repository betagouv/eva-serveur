require 'rails_helper'

describe ImportExport::Questions::Export::QuestionSousConsigne do
  include_context 'export'

  let(:type) { 'QuestionSousConsigne' }
  let(:question) do
    create(:question_sous_consigne, description: 'Ceci est une description',
                                    nom_technique: 'clic')
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
      QuestionSousConsigne::QUESTION_TYPE
    ]
    expect(headers_xls).to eq headers_attendus
  end

  it 'génére un fichier xls avec les détails de la question' do
    ligne = worksheet.row(1)
    expect(ligne[0]).to eq('Question sous consigne')
    expect(ligne[1]).to eq('clic')
    expect(ligne[2]).to be_nil
    expect(ligne[3]).to eq('Ceci est un intitulé')
    expect(ligne[4]).to eq(intitule.audio_url)
  end
end
