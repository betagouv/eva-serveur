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

  it "ne vole pas les choix d'une autre question lors de la création" do
    autre_question = create(:question_qcm)
    choix_existant = create(:choix, :bon, question_id: autre_question.id,
                                         nom_technique: 'Choix1', intitule: 'Choix1')

    service.import_from_xls(file)
    question = Question.where.not(id: autre_question.id).first

    expect(choix_existant.reload.question_id).to eq(autre_question.id)
    expect(question.choix.find_by(nom_technique: 'Choix1')).to be_present
  end

  it 'supprime les choix absents du fichier importé' do
    service.import_from_xls(file)
    question = Question.first
    choix_extra = create(:choix, :mauvais, question_id: question.id, nom_technique: 'ChoixExtra',
                                           intitule: 'Choix extra')

    service.import_from_xls(file)

    expect(Choix.exists?(id: choix_extra.id)).to be false
  end
end
