# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Export do
  subject(:response_service) { described_class.new([question], headers) }

  let(:headers) { [] }
  let(:question) { create(:question) }
  let(:spreadsheet) { Spreadsheet.open(StringIO.new(response_service.to_xls)) }
  let(:worksheet) { spreadsheet.worksheet(0) }

  describe 'pour une question clic' do
    let(:question) do
      create(:question_clic_dans_image, description: 'Ceci est une description',
                                        nom_technique: 'clic')
    end
    let!(:intitule) do
      create(:transcription, :avec_audio, question_id: question.id, categorie: :intitule,
                                          ecrit: 'Ceci est un intitulé')
    end
    let!(:consigne) do
      create(:transcription, :avec_audio, question_id: question.id,
                                          categorie: :modalite_reponse,
                                          ecrit: 'Ceci est une consigne')
    end
    let(:headers) do
      ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
    end

    it 'génére un fichier xls avec les entêtes sur chaque colonnes' do
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
      ligne = worksheet.row(1)
      expect(ligne[0]).to eq('Question clic dans image')
      expect(ligne[1]).to eq('clic')
      expect(ligne[2]).to be_nil
      expect(ligne[3]).to eq('Ceci est un intitulé')
      expect(ligne[4]).to eq(intitule.audio_url)
      expect(ligne[5]).to eq('Ceci est une consigne')
      expect(ligne[6]).to eq(consigne.audio_url)
      expect(ligne[7]).to eq('Ceci est une description')
      expect(ligne[8]).to eq(question.zone_cliquable_url)
      expect(ligne[9]).to eq(question.image_au_clic_url)
    end
  end

  describe 'pour une question glisser deposer' do
    let(:question) { create(:question_glisser_deposer) }
    let(:headers) do
      ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
    end
    let!(:reponse) { create(:choix, :bon, question_id: question.id) }
    let!(:reponse2) { create(:choix, :mauvais, question_id: question.id) }

    it 'génére un fichier xls avec les entêtes spécifiques' do
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
      ligne = worksheet.row(1)
      expect(ligne[8]).to eq(question.zone_depot_url)
      expect(ligne[9]).to eq(reponse.nom_technique)
      expect(ligne[10]).to eq(reponse.position_client)
      expect(ligne[11]).to eq(reponse.type_choix)
      expect(ligne[12]).to eq(reponse.illustration_url)
      expect(ligne[13]).to eq(reponse2.nom_technique)
      expect(ligne[14]).to eq(reponse2.position_client)
      expect(ligne[15]).to eq(reponse2.type_choix)
      expect(ligne[16]).to eq(reponse2.illustration_url)
    end
  end

  describe 'pour une question saisie' do
    let(:question) { create(:question_saisie) }
    let(:headers) do
      ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
    end
    let!(:reponse) { create(:choix, :bon, question_id: question.id) }

    it 'génére un fichier xls avec les entêtes spécifiques' do
      expect(spreadsheet.worksheets.count).to eq(1)
      expect(worksheet.row(0)[8]).to eq('Suffix reponse')
      expect(worksheet.row(0)[9]).to eq('Reponse placeholder')
      expect(worksheet.row(0)[10]).to eq('Type saisie')
      expect(worksheet.row(0)[11]).to eq('reponse_1_intitule')
      expect(worksheet.row(0)[12]).to eq('reponse_1_nom_technique')
      expect(worksheet.row(0)[13]).to eq('reponse_1_type_choix')
    end

    it 'génére un fichier xls avec les détails de la question' do
      ligne = worksheet.row(1)
      expect(ligne[8]).to eq(question.suffix_reponse)
      expect(ligne[9]).to eq(question.reponse_placeholder)
      expect(ligne[10]).to eq(question.type_saisie)
      expect(ligne[11]).to eq(question.reponses.last.intitule)
      expect(ligne[12]).to eq(question.reponses.last.nom_technique)
    end
  end

  describe 'pour une question qcm' do
    let(:question) { create(:question_qcm) }
    let(:headers) do
      ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
    end
    let!(:reponse) { create(:choix, :bon, question_id: question.id) }
    let!(:reponse2) { create(:choix, :mauvais, question_id: question.id) }

    it 'génére un fichier xls avec les entêtes spécifiques' do
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
      ligne = worksheet.row(1)
      expect(ligne[8]).to eq(question.type_qcm)
      expect(ligne[9]).to eq(reponse.intitule)
      expect(ligne[10]).to eq(reponse.nom_technique)
      expect(ligne[11]).to eq(reponse.type_choix)
      expect(ligne[12]).to eq(reponse.audio_url)
      expect(ligne[13]).to eq(reponse2.intitule)
      expect(ligne[14]).to eq(reponse2.nom_technique)
      expect(ligne[15]).to eq(reponse2.type_choix)
      expect(ligne[16]).to eq(reponse2.audio_url)
    end
  end

  describe '#nom_du_fichier' do
    let(:question) { create(:question_qcm) }

    it 'genere le nom du fichier' do
      date = DateTime.current.strftime('%Y%m%d')
      nom_du_fichier_attendu = "#{date}-#{question.type}.xls"

      expect(response_service.nom_du_fichier(question.type)).to eq(nom_du_fichier_attendu)
    end
  end

  describe '#content_type_xls' do
    it { expect(response_service.content_type_xls).to eq 'application/vnd.ms-excel' }
  end
end
