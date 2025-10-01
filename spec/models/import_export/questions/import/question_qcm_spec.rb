require 'rails_helper'

describe ImportExport::Questions::Import::QuestionQcm do
  let(:type) { 'QuestionQcm' }
  let(:file) do
    file_fixture_upload('spec/support/import_question_qcm.xls', 'text/xls')
  end

  include_context 'import'

  it 'importe les données spécifiques' do
    service.import_from_xls(file)
    expect(Question.count).to eq 2
    question = Question.first
    expect(question.type_qcm).to eq 'standard'
  end

  it 'crée les choix' do
    service.import_from_xls(file)
    choix = Question.first.choix
    expect(choix.count).to eq 2
    choix1 = choix.first
    expect(choix1.intitule).to eq 'Choix1'
    expect(choix1.nom_technique).to eq 'Choix1'
    expect(choix1.type_choix).to eq 'bon'
    expect(choix1.audio.attached?).to be true
    expect(choix1.illustration.attached?).to be true
    choix2 = choix.last
    expect(choix2.intitule).to eq 'Choix2'
    expect(choix2.nom_technique).to eq 'Choix2'
    expect(choix2.type_choix).to eq 'mauvais'
    expect(choix2.audio.attached?).to be true
    expect(choix2.illustration.attached?).to be true
  end
end
