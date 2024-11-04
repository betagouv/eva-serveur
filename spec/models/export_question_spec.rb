# frozen_string_literal: true

require 'rails_helper'

describe ExportQuestion do
  describe 'pour tous les types de questions' do
    subject(:response_service) do
      described_class.new(question_clic, headers)
    end

    let(:question_clic) do
      create(:question_clic_dans_image, description: 'Ceci est une description',
                                        nom_technique: 'clic')
    end
    let!(:intitule) do
      create(:transcription, :avec_audio, question_id: question_clic.id, categorie: :intitule,
                                          ecrit: 'Ceci est un intitulé')
    end
    let!(:consigne) do
      create(:transcription, :avec_audio, question_id: question_clic.id,
                                          categorie: :modalite_reponse,
                                          ecrit: 'Ceci est une consigne')
    end
    let(:headers) do
      ImportExportQuestion::HEADERS_ATTENDUS[question_clic.type]
    end

    describe '#to_xls' do
      it 'génére un fichier xls avec les entêtes sur chaque colonnes' do
        xls = response_service.to_xls
        spreadsheet = Spreadsheet.open(StringIO.new(xls))
        worksheet = spreadsheet.worksheet(0)

        expect(spreadsheet.worksheets.count).to eq(1)
        expect(worksheet.row(0)[0]).to eq('Libelle')
        expect(worksheet.row(0)[1]).to eq('Nom technique')
        expect(worksheet.row(0)[2]).to eq('Illustration')
        expect(worksheet.row(0)[3]).to eq('Intitule ecrit')
        expect(worksheet.row(0)[4]).to eq('Intitule audio')
        expect(worksheet.row(0)[5]).to eq('Consigne ecrit')
        expect(worksheet.row(0)[6]).to eq('Consigne audio')
        expect(worksheet.row(0)[7]).to eq('Description')
        expect(worksheet.row(0)[8]).to eq('Zone cliquable')
        expect(worksheet.row(0)[9]).to eq('Image au clic')
      end

      it 'génére un fichier xls avec les détails de la question' do
        xls = response_service.to_xls
        spreadsheet = Spreadsheet.open(StringIO.new(xls))
        worksheet = spreadsheet.worksheet(0)
        question = worksheet.row(1)
        expect(question[0]).to eq('Question clic dans image')
        expect(question[1]).to eq('clic')
        expect(question[2]).to be_nil
        expect(question[3]).to eq('Ceci est un intitulé')
        expect(question[4]).to eq(intitule.audio_url)
        expect(question[5]).to eq('Ceci est une consigne')
        expect(question[6]).to eq(consigne.audio_url)
        expect(question[7]).to eq('Ceci est une description')
        expect(question[8]).to eq(question_clic.zone_cliquable_url)
        expect(question[9]).to eq(question_clic.image_au_clic_url)
      end
    end

    describe '#nom_du_fichier' do
      it 'genere le nom du fichier' do
        date = DateTime.current.strftime('%Y%m%d')
        nom_du_fichier_attendu = "#{date}-#{question_clic.nom_technique}.xls"

        expect(response_service.nom_du_fichier).to eq(nom_du_fichier_attendu)
      end
    end

    describe '#content_type_xls' do
      it { expect(response_service.content_type_xls).to eq 'application/vnd.ms-excel' }
    end
  end

  describe 'pour une question glisser deposer' do
    subject(:response_service) do
      described_class.new(question_glisser_deposer, headers)
    end

    let(:question_glisser_deposer) { create(:question_glisser_deposer) }
    let(:headers) do
      ImportExportQuestion::HEADERS_ATTENDUS[question_glisser_deposer.type]
    end
    let!(:reponse) { create(:choix, :bon, question_id: question_glisser_deposer.id) }
    let!(:reponse2) { create(:choix, :mauvais, question_id: question_glisser_deposer.id) }

    it 'génére un fichier xls avec les entêtes spécifiques' do
      xls = response_service.to_xls
      spreadsheet = Spreadsheet.open(StringIO.new(xls))
      worksheet = spreadsheet.worksheet(0)

      expect(spreadsheet.worksheets.count).to eq(1)
      expect(worksheet.row(0)[8]).to eq('Zone depot')
      expect(worksheet.row(0)[9]).to eq('reponse_1_nom_technique')
      expect(worksheet.row(0)[10]).to eq('reponse_1_position_client')
      expect(worksheet.row(0)[11]).to eq('reponse_1_type_choix')
      expect(worksheet.row(0)[12]).to eq('reponse_1_illustration')
      expect(worksheet.row(0)[13]).to eq('reponse_2_nom_technique')
      expect(worksheet.row(0)[14]).to eq('reponse_2_position_client')
      expect(worksheet.row(0)[15]).to eq('reponse_2_type_choix')
      expect(worksheet.row(0)[16]).to eq('reponse_2_illustration')
    end

    it 'génére un fichier xls avec les détails de la question' do
      xls = response_service.to_xls
      spreadsheet = Spreadsheet.open(StringIO.new(xls))
      worksheet = spreadsheet.worksheet(0)
      question = worksheet.row(1)
      expect(question[8]).to eq(question_glisser_deposer.zone_depot_url)
      expect(question[9]).to eq(reponse.nom_technique)
      expect(question[10]).to eq(reponse.position_client)
      expect(question[11]).to eq(reponse.type_choix)
      expect(question[12]).to eq(reponse.illustration_url)
      expect(question[13]).to eq(reponse2.nom_technique)
      expect(question[14]).to eq(reponse2.position_client)
      expect(question[15]).to eq(reponse2.type_choix)
      expect(question[16]).to eq(reponse2.illustration_url)
    end
  end

  describe 'pour une question saisie' do
    subject(:response_service) do
      described_class.new(question_saisie, headers)
    end

    let(:question_saisie) { create(:question_saisie) }
    let(:headers) do
      ImportExportQuestion::HEADERS_ATTENDUS[question_saisie.type]
    end
    let!(:reponse) { create(:choix, :bon, question_id: question_saisie.id) }

    it 'génére un fichier xls avec les entêtes spécifiques' do
      xls = response_service.to_xls
      spreadsheet = Spreadsheet.open(StringIO.new(xls))
      worksheet = spreadsheet.worksheet(0)

      expect(spreadsheet.worksheets.count).to eq(1)
      expect(worksheet.row(0)[8]).to eq('Suffix reponse')
      expect(worksheet.row(0)[9]).to eq('Reponse placeholder')
      expect(worksheet.row(0)[10]).to eq('Type saisie')
      expect(worksheet.row(0)[11]).to eq('Bonne reponse intitule')
      expect(worksheet.row(0)[12]).to eq('Bonne reponse nom technique')
    end

    it 'génére un fichier xls avec les détails de la question' do
      xls = response_service.to_xls
      spreadsheet = Spreadsheet.open(StringIO.new(xls))
      worksheet = spreadsheet.worksheet(0)
      question = worksheet.row(1)
      expect(question[8]).to eq(question_saisie.suffix_reponse)
      expect(question[9]).to eq(question_saisie.reponse_placeholder)
      expect(question[10]).to eq(question_saisie.type_saisie)
      expect(question[11]).to eq(question_saisie.bonne_reponse.intitule)
      expect(question[12]).to eq(question_saisie.bonne_reponse.nom_technique)
    end
  end

  describe 'pour une question qcm' do
    subject(:response_service) do
      described_class.new(question_qcm, headers)
    end

    let(:question_qcm) { create(:question_qcm) }
    let(:headers) do
      ImportExportQuestion::HEADERS_ATTENDUS[question_qcm.type]
    end
    let!(:reponse) { create(:choix, :bon, question_id: question_qcm.id) }
    let!(:reponse2) { create(:choix, :mauvais, question_id: question_qcm.id) }

    it 'génére un fichier xls avec les entêtes spécifiques' do
      xls = response_service.to_xls
      spreadsheet = Spreadsheet.open(StringIO.new(xls))
      worksheet = spreadsheet.worksheet(0)

      expect(spreadsheet.worksheets.count).to eq(1)
      expect(worksheet.row(0)[8]).to eq('Type qcm')
      expect(worksheet.row(0)[9]).to eq('choix_1_intitule')
      expect(worksheet.row(0)[10]).to eq('choix_1_nom_technique')
      expect(worksheet.row(0)[11]).to eq('choix_1_type_choix')
      expect(worksheet.row(0)[12]).to eq('choix_1_audio')
      expect(worksheet.row(0)[13]).to eq('choix_2_intitule')
      expect(worksheet.row(0)[14]).to eq('choix_2_nom_technique')
      expect(worksheet.row(0)[15]).to eq('choix_2_type_choix')
      expect(worksheet.row(0)[16]).to eq('choix_2_audio')
    end

    it 'génére un fichier xls avec les détails de la question' do
      xls = response_service.to_xls
      spreadsheet = Spreadsheet.open(StringIO.new(xls))
      worksheet = spreadsheet.worksheet(0)
      question = worksheet.row(1)
      expect(question[8]).to eq(question_qcm.type_qcm)
      expect(question[9]).to eq(reponse.intitule)
      expect(question[10]).to eq(reponse.nom_technique)
      expect(question[11]).to eq(reponse.type_choix)
      expect(question[12]).to eq(reponse.audio_url)
      expect(question[13]).to eq(reponse2.intitule)
      expect(question[14]).to eq(reponse2.nom_technique)
      expect(question[15]).to eq(reponse2.type_choix)
      expect(question[16]).to eq(reponse2.audio_url)
    end
  end
end
