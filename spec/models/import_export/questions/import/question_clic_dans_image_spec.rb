# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Import::QuestionClicDansImage do
  let(:type) { 'QuestionClicDansImage' }
  let(:file) do
    file_fixture_upload('spec/support/import_question_clic.xls', 'text/xls')
  end

  include_context 'import'

  before do
    # Stub les URLS présentes dans les fichiers de test XLS
    stub_request(:get, 'https://serveur/choix1.mp3')
    stub_request(:get, 'https://serveur/choix2.mp3')
    stub_request(:get, 'https://serveur/consigne.mp3')
    stub_request(:get, 'https://serveur/illustration.png')
    stub_request(:get, 'https://serveur/image_au_clic.svg')
    stub_request(:get, 'https://serveur/intitule.mp3')
    stub_request(:get, 'https://serveur/reponse1.png')
    stub_request(:get, 'https://serveur/reponse2.png')
    stub_request(:get, 'https://serveur/zone_clicable.svg')
      .to_return(status: 200,
                 body: Rails.root.join('spec/support/zone-clicable-valide.svg').read)
    stub_request(:get, 'https://serveur/zone_depot.svg')
      .to_return(status: 200,
                 body: Rails.root.join('spec/support/N1Pse1-zone-depot-valide.svg').read)
  end

  it 'importe les données spécifiques' do
    service.import_from_xls(file)
    question = Question.last
    expect(question.zone_cliquable.attached?).to be true
    expect(question.image_au_clic.attached?).to be true
  end
end
