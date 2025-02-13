# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Import::QuestionSaisie do
  let(:type) { 'QuestionSaisie' }
  let(:file) do
    file_fixture_upload('spec/support/import_question_saisie.xls', 'text/xls')
  end

  include_context 'import'

  it 'importe les données spécifiques' do
    service.import_from_xls(file)
    question = Question.last
    expect(question.suffix_reponse).to eq 'suffixe'
    expect(question.reponse_placeholder).to eq 'placeholder'
    expect(question.type_saisie).to eq 'numerique'
    expect(question.texte_a_trous).to eq '<html>'
    expect(question.reponses.first.intitule).to eq '9'
    expect(question.reponses.first.nom_technique).to eq 'reponse1'
    expect(question.reponses.first.type_choix).to eq 'acceptable'
    expect(question.reponses.second.intitule).to eq '10'
    expect(question.reponses.second.nom_technique).to eq 'reponse2'
    expect(question.reponses.second.type_choix).to eq 'bon'
  end
end
