# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Export do
  subject(:response_service) do
    response_service = exporteur.new(
      [question], ImportExport::Questions::ImportExportDonnees::HEADERS_COMMUN
    )
    response_service.to_xls
    response_service
  end

  let(:exporteur) { described_class }
  let(:headers) { [] }
  let(:question) { create(:question) }
  let(:spreadsheet) { response_service.export.workbook }
  let(:worksheet) { spreadsheet.worksheet(0) }
  let(:headers_xls) { worksheet.row(0).map { |header| header.parameterize.underscore.to_sym } }

  describe 'pour une question clic dans image' do
    let(:exporteur) { ImportExport::Questions::Export::QuestionClicDansImage }
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

      headers_attendus = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[
        QuestionClicDansImage::QUESTION_TYPE
      ]
      expect(headers_xls).to eq headers_attendus
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
    let(:exporteur) { ImportExport::Questions::Export::QuestionGlisserDeposer }
    let!(:question) { create(:question_glisser_deposer) }
    let(:headers) do
      ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
    end
    let!(:reponse) { create(:choix, :bon, question_id: question.id) }
    let!(:reponse2) { create(:choix, :mauvais, question_id: question.id) }

    it 'génére un fichier xls avec les entêtes spécifiques' do
      expect(spreadsheet.worksheets.count).to eq(1)

      headers_attendus = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[
        QuestionGlisserDeposer::QUESTION_TYPE
      ]
      headers_attendus += %i[reponse_1_nom_technique reponse_1_position_client reponse_1_type_choix
                             reponse_1_illustration_url reponse_2_nom_technique
                             reponse_2_position_client reponse_2_type_choix
                             reponse_2_illustration_url]

      expect(headers_xls).to eq headers_attendus
    end

    it 'génére un fichier xls avec les détails de la question' do
      ligne = worksheet.row(1)

      expect(ligne[8]).to eq(question.zone_depot_url)
      expect(ligne[9]).to eq(question.orientation)
      expect(ligne[10]).to eq(reponse.nom_technique)
      expect(ligne[11]).to eq(reponse.position_client.to_s)
      expect(ligne[12]).to eq(reponse.type_choix)
      expect(ligne[13]).to eq(reponse.illustration_url.to_s)
      expect(ligne[14]).to eq(reponse2.nom_technique)
      expect(ligne[15]).to eq(reponse2.position_client.to_s)
      expect(ligne[16]).to eq(reponse2.type_choix)
      expect(ligne[17]).to eq(reponse2.illustration_url.to_s)
    end
  end

  describe 'pour une question saisie' do
    let(:exporteur) { ImportExport::Questions::Export::QuestionSaisie }
    let(:question) { create(:question_saisie) }
    let(:headers) do
      ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
    end
    let!(:reponse) { create(:choix, :bon, question_id: question.id) }

    it 'génére un fichier xls avec les entêtes spécifiques' do
      expect(spreadsheet.worksheets.count).to eq(1)

      headers_attendus = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[
        QuestionSaisie::QUESTION_TYPE
      ]
      headers_attendus += %i[reponse_1_intitule reponse_1_nom_technique reponse_1_type_choix]

      expect(headers_xls).to eq headers_attendus
    end

    it 'génére un fichier xls avec les détails de la question' do
      ligne = worksheet.row(1)
      expect(ligne[8]).to eq(question.suffix_reponse)
      expect(ligne[9]).to eq(question.reponse_placeholder)
      expect(ligne[10]).to eq(question.type_saisie)
      expect(ligne[11]).to eq(question.texte_a_trous)
      expect(ligne[12]).to eq(question.reponses.last.intitule)
      expect(ligne[13]).to eq(question.reponses.last.nom_technique)
    end
  end

  describe 'pour une question qcm' do
    let(:exporteur) { ImportExport::Questions::Export::QuestionQcm }
    let(:question) { create(:question_qcm) }
    let(:headers) do
      ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[question.type]
    end
    let!(:reponse) { create(:choix, :bon, question_id: question.id) }
    let!(:reponse2) { create(:choix, :mauvais, question_id: question.id) }

    it 'génére un fichier xls avec les entêtes spécifiques' do
      expect(spreadsheet.worksheets.count).to eq(1)

      headers_attendus = ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[
        QuestionQcm::QUESTION_TYPE
      ]
      headers_attendus += %i[choix_1_intitule choix_1_nom_technique choix_1_type_choix
                             choix_1_audio_url choix_2_intitule choix_2_nom_technique
                             choix_2_type_choix choix_2_audio_url]

      expect(headers_xls).to eq headers_attendus
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
