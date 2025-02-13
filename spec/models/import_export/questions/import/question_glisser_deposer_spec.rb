# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Import::QuestionGlisserDeposer do
  include ActionDispatch::TestProcess::FixtureFile

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

  describe 'pour une question de type glisser deposer' do
    subject(:service) do
      described_class.new(headers)
    end

    let(:type_glisser) { 'QuestionGlisserDeposer' }
    let(:headers) do
      ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_glisser]
    end
    let(:file) do
      file_fixture_upload('spec/support/import_question_glisser.xls', 'text/xls')
    end

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
end
