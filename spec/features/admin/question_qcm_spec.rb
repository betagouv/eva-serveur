# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Question QCM', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'index' do
    let!(:question) do
      create :question_qcm
    end
    let!(:transcription) do
      create :transcription, question_id: question.id, ecrit: 'Comment ça va ?'
    end

    before { visit admin_question_qcms_path }

    it do
      expect(page).to have_content 'Comment ça va ?'
    end

    it "redirige vers le formulaire d'importation de question" do
      within('.action-items-sidebar') do
        click_on 'Importer question qcm'
      end
      expect(page).to have_content 'Importer question'
    end
  end

  describe 'création' do
    before do
      visit new_admin_question_qcm_path
    end

    context 'sans transcriptions' do
      before do
        fill_in :question_qcm_libelle, with: 'Question'
        fill_in :question_qcm_nom_technique, with: 'question'
      end

      it 'créé une nouvelle question' do
        expect { click_on 'Créer' }.to(change(Question, :count))
        expect(Question.first.transcriptions).to be_empty
      end
    end

    context 'quand une transcription pour intitule est ajouté' do
      before do
        fill_in :question_qcm_libelle, with: 'Question'
        fill_in :question_qcm_nom_technique, with: 'question'
        fill_in :question_qcm_transcriptions_attributes_0_ecrit, with: 'Intitulé'
        click_on 'Créer'
      end

      it do
        expect(Question.first.transcriptions.count).to eq 1
        expect(Question.first.transcription_intitule&.ecrit).to eq 'Intitulé'
      end
    end

    context 'quand une transcription pour modalité réponse est ajoutée' do
      before do
        fill_in :question_qcm_libelle, with: 'Question'
        fill_in :question_qcm_nom_technique, with: 'question'
        fill_in :question_qcm_transcriptions_attributes_1_ecrit, with: 'Consigne'
        click_on 'Créer'
      end

      it do
        expect(Question.first.transcriptions.count).to eq 1
        expect(Question.first.transcription_modalite_reponse&.ecrit).to eq 'Consigne'
      end
    end

    context 'quand une transcription pour consigne est ajoutée' do
      before do
        fill_in :question_qcm_libelle, with: 'Question'
        fill_in :question_qcm_nom_technique, with: 'question'
        attach_file(:question_qcm_transcriptions_attributes_2_audio,
                    Rails.root.join('spec/support/alcoolique.mp3'))
        click_on 'Créer'
      end

      it do
        expect(Question.first.transcriptions.count).to eq 1
        expect(Question.first.transcription_consigne&.audio&.attached?).to be true
      end
    end

    context 'quand une illustration est ajoutée' do
      before do
        fill_in :question_qcm_libelle, with: 'Question'
        fill_in :question_qcm_nom_technique, with: 'question'
        attach_file(:question_qcm_illustration, Rails.root.join('spec/support/programme_tele.png'))
        click_on 'Créer'
      end

      it do
        expect(Question.first.illustration.attached?).to be true
      end
    end
  end

  describe 'modification' do
    let!(:question) do
      create :question_qcm,
             illustration: Rack::Test::UploadedFile.new(
               Rails.root.join('spec/support/programme_tele.png')
             )
    end
    let!(:transcription) do
      create :transcription, question_id: question.id, ecrit: 'Comment ça va ?'
    end

    let!(:modalite_reponse) do
      create :transcription, :avec_audio, question_id: question.id, ecrit: 'Comment ça va ?',
                                          categorie: :modalite_reponse
    end

    let!(:consigne) do
      create :transcription, :avec_audio, question_id: question.id, categorie: :consigne
    end

    context "quand l'admin supprime l'écrit d'une transcription et qu'il n'y a pas d'audio" do
      before do
        visit edit_admin_question_qcm_path(question)
        fill_in :question_qcm_transcriptions_attributes_0_ecrit, with: ''
      end

      it 'supprime la transcription' do
        expect(Question.first.transcriptions.count).to eq 3
        click_on 'Enregistrer'
        expect(Question.first.transcriptions.count).to eq 2
      end
    end

    context "quand l'admin coche supprimer l'illustration" do
      before do
        visit edit_admin_question_qcm_path(question)
        check 'question_qcm_supprimer_illustration'
      end

      it "supprime l'illustration" do
        expect(question.illustration.attached?).to be true
        click_on 'Enregistrer'
        question.reload
        expect(question.illustration.attached?).to be false
      end
    end

    context "quand l'admin coche supprimer l'audio de l'intitulé" do
      before do
        Question.first.transcriptions.find_by(categorie: :intitule)
                .update(audio: Rack::Test::UploadedFile.new(
                  Rails.root.join('spec/support/alcoolique.mp3')
                ))
        visit edit_admin_question_qcm_path(question)
        check 'question_qcm_supprimer_audio_intitule'
      end

      it "supprime l'audio" do
        expect(
          Question.first.transcriptions.find_by(categorie: :intitule).audio.attached?
        ).to be true
        click_on 'Enregistrer'
        question.reload
        expect(
          Question.first.transcriptions.find_by(categorie: :intitule).audio.attached?
        ).to be false
      end
    end

    context "quand l'admin coche supprimer l'audio de la modalité de réponse" do
      before do
        Question.first.transcriptions.find_by(categorie: :modalite_reponse)
                .update(audio: Rack::Test::UploadedFile.new(
                  Rails.root.join('spec/support/alcoolique.mp3')
                ))
        visit edit_admin_question_qcm_path(question)
        check 'question_qcm_supprimer_audio_modalite_reponse'
      end

      it "supprime l'audio" do
        expect(
          Question.first.transcriptions.find_by(categorie: :modalite_reponse).audio.attached?
        ).to be true
        click_on 'Enregistrer'
        question.reload
        expect(
          Question.first.transcriptions.find_by(categorie: :modalite_reponse).audio.attached?
        ).to be false
      end
    end

    context "quand l'admin coche supprimer l'audio de la consigne" do
      before do
        Question.first.transcriptions.find_by(categorie: :consigne)
                .update(audio: Rack::Test::UploadedFile.new(
                  Rails.root.join('spec/support/alcoolique.mp3')
                ))
        visit edit_admin_question_qcm_path(question)
        check 'question_qcm_supprimer_audio_consigne'
      end

      it "supprime l'audio" do
        expect(
          Question.first.transcriptions.find_by(categorie: :consigne).audio.attached?
        ).to be true
        click_on 'Enregistrer'
        question.reload
        expect(
          Question.first.transcriptions.find_by(categorie: :consigne).audio.attached?
        ).to be false
      end
    end
  end
end
