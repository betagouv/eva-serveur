# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Export::QuestionClicDansTexte do
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

  let(:question) do
    create(:question_clic_dans_image, description: 'Ceci est une description',
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
  let(:headers) do
    ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
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
    expect(ligne[2]).to be_nil
    expect(ligne[3]).to eq('Ceci est un intitulé')
    expect(ligne[4]).to eq(intitule.audio_url)
    expect(ligne[5]).to eq('Ceci est une consigne')
    expect(ligne[6]).to eq(consigne.audio_url)
    expect(ligne[7]).to eq('Ceci est une description')
    expect(ligne[8]).to eq(question.texte_sur_illustration)
  end
end
