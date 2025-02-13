# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Import::QuestionSousConsigne do
  include ActionDispatch::TestProcess::FixtureFile
  
  subject(:service) do
    described_class.new(headers)
  end

  let(:type_consigne) { 'QuestionSousConsigne' }
  let(:headers) do
    ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_consigne]
  end
  let(:file) do
    file_fixture_upload('spec/support/import_question_consigne.xls', 'text/xls')
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

  it 'importe les données' do
    service.import_from_xls(file)
    question = Question.last
    expect(question.nom_technique).to eq 'N1Pse6'
    expect(question.libelle).to eq 'N1Pse6'
  end

  it "créé la transcription de li'intitulé seulement" do
    service.import_from_xls(file)
    transcriptions = Question.last.transcriptions
    expect(transcriptions.count).to eq 1
    expect(transcriptions.first.categorie).to eq 'intitule'
    expect(transcriptions.first.ecrit).to eq 'Ceci est un intitulé'
    expect(transcriptions.first.audio.attached?).to be true
  end
end
