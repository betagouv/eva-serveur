# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Import::QuestionGlisserDeposer do
  let(:type) { 'QuestionGlisserDeposer' }
  let(:file) do
    file_fixture_upload('spec/support/import_question_glisser.xls', 'text/xls')
  end

  include_context 'import'

  it 'importe les données spécifiques' do
    service.import_from_xls(file)
    question = Question.last
    expect(question.zone_depot.attached?).to be true
  end

  it 'crée les réponses' do
    service.import_from_xls(file)
    reponses = Question.last.reponses
    expect(reponses.count).to eq 2
    reponse1 = reponses.first
    expect(reponse1.nom_technique).to eq 'N2Pon2R1'
    expect(reponse1.position_client).to eq 2
    expect(reponse1.type_choix).to eq 'bon'
    expect(reponse1.illustration.attached?).to be true
    reponse2 = reponses.last
    expect(reponse2.nom_technique).to eq 'N2Pon2R2'
    expect(reponse2.position_client).to eq 1
    expect(reponse1.type_choix).to eq 'bon'
    expect(reponse2.illustration.attached?).to be true
  end
end
