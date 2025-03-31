# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Import do
  let(:type) { 'QuestionClicDansImage' }

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

  describe 'avec un fichier valide' do
    let(:file) do
      file_fixture_upload('spec/support/import_question_clic.xls', 'text/xls')
    end

    it 'importe une nouvelle question' do
      expect do
        service.import_from_xls(file)
      end.to change(Question, :count).by(2)
    end

    it 'crée les transcriptions' do
      service.import_from_xls(file)
      transcriptions = Question.last.transcriptions
      expect(transcriptions.count).to eq 2
      expect(transcriptions.first.categorie).to eq 'intitule'
      expect(transcriptions.first.ecrit).to eq 'Ceci est un intitulé'
      expect(transcriptions.first.audio.attached?).to be true
      expect(transcriptions.last.categorie).to eq 'modalite_reponse'
      expect(transcriptions.last.ecrit).to eq 'Ceci est une consigne'
      expect(transcriptions.last.audio.attached?).to be true
    end

    it "importe les données d'une question" do
      service.import_from_xls(file)
      question = Question.last
      expect(question.nom_technique).to eq 'N1Pse6'
      expect(question.libelle).to eq 'N1Pse6'
      expect(question.score).to eq 2
      expect(question.description).to eq 'Ceci est une description'
      expect(question.illustration.attached?).to be true
    end
  end

  describe 'avec un fichier invalide' do
    let(:file) do
      file_fixture_upload('spec/support/import_question_invalide.xls', 'text/xls')
    end

    it 'renvoie une erreur avec les headers manquants' do
      message = service.send(:message_erreur_headers)

      expect do
        service.import_from_xls(file)
      end.to raise_error(ImportExport::Questions::Import::Error, message)
    end
  end
end
