# frozen_string_literal: true

require 'rails_helper'

describe ImportQuestion do
  describe 'pour toutes les questions' do
    subject(:service) do
      described_class.new('QuestionClicDansImage')
    end

    describe 'avec un fichier valide' do
      let(:file) do
        fixture_file_upload('spec/support/import_question_clic.xls', 'text/xls')
      end

      it 'importe une nouvelle question' do
        expect do
          service.remplis_donnees(file)
        end.to change(Question, :count).by(1)
      end

      it 'crée les transcriptions' do
        service.remplis_donnees(file)
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
        service.remplis_donnees(file)
        question = Question.last
        expect(question.nom_technique).to eq 'N1Pse5'
        expect(question.libelle).to eq 'N1Pse5'
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
          service.remplis_donnees(file)
        end.to raise_error(ImportQuestion::Error, message)
      end
    end
  end

  describe 'pour une question de type qcm' do
    subject(:service) do
      described_class.new('QuestionQcm')
    end

    let(:file) do
      fixture_file_upload('spec/support/import_question_qcm.xls', 'text/xls')
    end

    it 'importe les données spécifiques' do
      service.remplis_donnees(file)
      question = Question.last
      expect(question.type_qcm).to eq 'standard'
    end

    it 'crée les choix' do
      service.remplis_donnees(file)
      choix = Question.last.choix
      expect(choix.count).to eq 2
      choix1 = Choix.first
      expect(choix1.intitule).to eq 'Choix1'
      expect(choix1.nom_technique).to eq 'Choix1'
      expect(choix1.type_choix).to eq 'bon'
      expect(choix1.audio.attached?).to be true
      choix2 = Choix.last
      expect(choix2.intitule).to eq 'Choix2'
      expect(choix2.nom_technique).to eq 'Choix2'
      expect(choix2.type_choix).to eq 'mauvais'
      expect(choix2.audio.attached?).to be true
    end
  end

  describe 'pour une question de type glisser deposer' do
    subject(:service) do
      described_class.new('QuestionGlisserDeposer')
    end

    let(:file) do
      fixture_file_upload('spec/support/import_question_glisser.xls', 'text/xls')
    end

    it 'importe les données spécifiques' do
      service.remplis_donnees(file)
      question = Question.last
      expect(question.zone_depot.attached?).to eq true
    end

    it 'crée les réponses' do
      service.remplis_donnees(file)
      reponses = Question.last.reponses
      expect(reponses.count).to eq 2
      reponse1 = reponses.first
      expect(reponse1.nom_technique).to eq 'reponse1'
      expect(reponse1.position_client).to eq 2
      expect(reponse1.type_choix).to eq 'bon'
      expect(reponse1.illustration.attached?).to be true
      reponse2 = reponses.last
      expect(reponse2.nom_technique).to eq 'reponse2'
      expect(reponse2.position_client).to eq 1
      expect(reponse1.type_choix).to eq 'bon'
      expect(reponse2.illustration.attached?).to be true
    end
  end

  describe 'pour une question de type clic dans image' do
    subject(:service) do
      described_class.new('QuestionClicDansImage')
    end

    let(:file) do
      fixture_file_upload('spec/support/import_question_clic.xls', 'text/xls')
    end

    it 'importe les données spécifiques' do
      service.remplis_donnees(file)
      question = Question.last
      expect(question.image_au_clic.attached?).to eq true
    end
  end

  describe 'pour une question de type saisie' do
    subject(:service) do
      described_class.new('QuestionSaisie')
    end

    let(:file) do
      fixture_file_upload('spec/support/import_question_saisie.xls', 'text/xls')
    end

    it 'importe les données spécifiques' do
      service.remplis_donnees(file)
      question = Question.last
      expect(question.suffix_reponse).to eq 'suffixe'
      expect(question.reponse_placeholder).to eq 'placeholder'
      expect(question.type_saisie).to eq 'numerique'
      expect(question.bonne_reponse.intitule).to eq '9'
      expect(question.bonne_reponse.nom_technique).to eq '9'
    end
  end

  describe 'pour une question de type sous consigne' do
    subject(:service) do
      described_class.new('QuestionSousConsigne')
    end

    let(:file) do
      fixture_file_upload('spec/support/import_question_consigne.xls', 'text/xls')
    end

    it 'importe les données' do
      service.remplis_donnees(file)
      question = Question.last
      expect(question.nom_technique).to eq 'N1Pse5'
      expect(question.libelle).to eq 'N1Pse5'
    end

    it "créé la transcription de li'intitulé seulement" do
      service.remplis_donnees(file)
      transcriptions = Question.last.transcriptions
      expect(transcriptions.count).to eq 1
      expect(transcriptions.first.categorie).to eq 'intitule'
      expect(transcriptions.first.ecrit).to eq 'Ceci est un intitulé'
      expect(transcriptions.first.audio.attached?).to be true
    end
  end
end
