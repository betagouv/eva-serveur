# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Import::QuestionQcm do
  include ActionDispatch::TestProcess::FixtureFile

  subject(:service) do
    described_class.new(headers)
  end

  let(:type_qcm) { 'QuestionQcm' }
  let(:headers) do
    ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_qcm]
  end
  let(:file) do
    file_fixture_upload('spec/support/import_question_qcm.xls', 'text/xls')
  end

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
    choix2 = choix.last
    expect(choix2.intitule).to eq 'Choix2'
    expect(choix2.nom_technique).to eq 'Choix2'
    expect(choix2.type_choix).to eq 'mauvais'
    expect(choix2.audio.attached?).to be true
  end
end
