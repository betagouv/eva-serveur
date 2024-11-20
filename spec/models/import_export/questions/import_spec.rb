# frozen_string_literal: true

require 'rails_helper'

describe ImportExport::Questions::Import do
  describe 'importe les données' do
    describe 'pour toutes les questions' do
      subject(:service) do
        described_class.new(type_clic, headers)
      end

      let(:type_clic) { 'QuestionClicDansImage' }

      let(:headers) do
        ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_clic]
      end

      describe 'avec un fichier valide' do
        let(:file) do
          fixture_file_upload('spec/support/import_question_clic.xls', 'text/xls')
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
          expect(question.description).to eq 'Ceci est une description'
          expect(question.illustration.attached?).to be true
        end
      end

      describe 'avec un fichier invalide' do
        let(:file) do
          fixture_file_upload('spec/support/import_question_invalide.xls', 'text/xls')
        end

        it 'renvoie une erreur avec les headers manquants' do
          message = service.send(:message_erreur_headers)

          expect do
            service.import_from_xls(file)
          end.to raise_error(ImportExport::Questions::Import::Error, message)
        end
      end
    end

    describe 'pour une question de type qcm' do
      subject(:service) do
        described_class.new(type_qcm, headers)
      end

      let(:type_qcm) { 'QuestionQcm' }

      let(:headers) do
        ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_qcm]
      end

      let(:file) do
        fixture_file_upload('spec/support/import_question_qcm.xls', 'text/xls')
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

    describe 'pour une question de type glisser deposer' do
      subject(:service) do
        described_class.new(type_glisser, headers)
      end

      let(:type_glisser) { 'QuestionGlisserDeposer' }

      let(:headers) do
        ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_glisser]
      end

      let(:file) do
        fixture_file_upload('spec/support/import_question_glisser.xls', 'text/xls')
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

    describe 'pour une question de type clic dans image' do
      subject(:service) do
        described_class.new(type_clic, headers)
      end

      let(:type_clic) { 'QuestionClicDansImage' }

      let(:headers) do
        ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_clic]
      end

      let(:file) do
        fixture_file_upload('spec/support/import_question_clic.xls', 'text/xls')
      end

      it 'importe les données spécifiques' do
        service.import_from_xls(file)
        question = Question.last
        expect(question.image_au_clic.attached?).to be true
        expect(question.zone_cliquable.attached?).to be true
      end
    end

    describe 'pour une question de type saisie' do
      subject(:service) do
        described_class.new(type_saisie, headers)
      end

      let(:type_saisie) { 'QuestionSaisie' }

      let(:headers) do
        ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_saisie]
      end

      let(:file) do
        fixture_file_upload('spec/support/import_question_saisie.xls', 'text/xls')
      end

      it 'importe les données spécifiques' do
        service.import_from_xls(file)
        question = Question.last
        expect(question.suffix_reponse).to eq 'suffixe'
        expect(question.reponse_placeholder).to eq 'placeholder'
        expect(question.type_saisie).to eq 'numerique'
        expect(question.texte_a_trous).to eq '<html>'
        expect(question.reponses.first.intitule).to eq '9'
        expect(question.reponses.first.nom_technique).to eq 'reponse1'
        expect(question.reponses.first.type_choix).to eq 'acceptable'
        expect(question.reponses.second.intitule).to eq '10'
        expect(question.reponses.second.nom_technique).to eq 'reponse2'
        expect(question.reponses.second.type_choix).to eq 'bon'
      end
    end

    describe 'pour une question de type sous consigne' do
      subject(:service) do
        described_class.new(type_consigne, headers)
      end

      let(:type_consigne) { 'QuestionSousConsigne' }

      let(:headers) do
        ImportExport::Questions::ImportExportDonnees::HEADERS_ATTENDUS[type_consigne]
      end

      let(:file) do
        fixture_file_upload('spec/support/import_question_consigne.xls', 'text/xls')
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
  end
end
