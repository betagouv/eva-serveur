# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::ImportExportDonnees do
  include ActionDispatch::TestProcess::FixtureFile

  describe '#exporte_donnees' do
    subject(:service) do
      described_class.new(questions: [question], type: question.type)
    end

    let!(:question) { create(:question_clic_dans_image) }

    it 'exporte les données' do
      date = DateTime.current.strftime('%Y%m%d')
      nom_du_fichier_attendu = "#{date}-#{question.type}.xls"
      expect(service.exporte_donnees[:xls]).not_to be_nil
      expect(service.exporte_donnees[:content_type]).to eq 'application/vnd.ms-excel'
      expect(service.exporte_donnees[:filename]).to eq nom_du_fichier_attendu
    end
  end

  describe '#importe_donnees' do
    subject(:service) do
      described_class.new(type: type)
    end

    let!(:type) { 'QuestionClicDansImage' }
    let!(:file) do
      file_fixture_upload('spec/support/import_question_clic.xls', 'text/xls')
    end

    it 'importe une nouvelle question' do
      stub_request(:get, 'https://serveur/illustration.png')
      stub_request(:get, 'https://serveur/intitule.mp3')
      stub_request(:get, 'https://serveur/consigne.mp3')
      stub_request(:get, 'https://serveur/image_au_clic.svg')
      stub_request(:get, 'https://serveur/zone_clicable.svg')
        .to_return(status: 200,
                   body: Rails.root.join('spec/support/zone-clicable-valide.svg').read)
      expect(Question.count).to eq 0
      expect do
        service.importe_donnees(file)
      end.to change(Question, :count).by(2)
    end
  end
end
