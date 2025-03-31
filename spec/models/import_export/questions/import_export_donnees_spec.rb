# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::ImportExportDonnees do
  include ActionDispatch::TestProcess::FixtureFile

  describe '#HEADERS_COMMUN' do
    it 'vérifie les colonnes spécifiques et ignorées' do
      columns_specifiques = %i[illustration intitule_audio intitule_ecrit libelle
                               nom_technique score]
      colonnes_ignorees_attendues = Question.column_names.map(&:to_sym) - columns_specifiques

      headers = ImportExport::Questions::ImportExportDonnees::HEADERS_COMMUN
      expect(headers).to match_array(columns_specifiques)
      expect(colonnes_ignorees_attendues).to contain_exactly(
        :aide,
        :categorie,
        :created_at,
        :deleted_at,
        :id,
        :orientation,
        :reponse_placeholder,
        :suffix_reponse,
        :texte_a_trous,
        :texte_sur_illustration,
        :type,
        :type_qcm,
        :type_saisie,
        :updated_at,
        :demarrage_audio_modalite_reponse,
        :description,
        :metacompetence
      )
    end
  end

  describe '#exporte_donnees' do
    subject(:service) do
      described_class.new(questions: [question], type: question.type)
    end

    let!(:question) { create(:question_clic_dans_image) }

    it 'exporte les données' do
      Timecop.freeze(Time.zone.local(2025, 2, 28, 1, 2, 3)) do
        nom_du_fichier_attendu = '20250228010203-QuestionClicDansImage.xls'
        expect(service.exporte_donnees[:xls]).not_to be_nil
        expect(service.exporte_donnees[:content_type]).to eq 'application/vnd.ms-excel'
        expect(service.exporte_donnees[:filename]).to eq nom_du_fichier_attendu
      end
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
