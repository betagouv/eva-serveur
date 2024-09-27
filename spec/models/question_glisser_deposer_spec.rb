# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Question Glisser Deposer', type: :feature do
  before(:each) { se_connecter_comme_superadmin }

  describe 'show' do
    let!(:question) do
      create :question_glisser_deposer, libelle: 'Libellé de la question'
    end
    let!(:transcription) do
      create :transcription, question_id: question.id, ecrit: 'Comment ça va ?'
    end

    before(:each) { visit admin_question_glisser_deposer_path(question) }

    it 'affiche le libellé de la question et la transcription associée' do
      expect(page).to have_content 'Libellé de la question'
      expect(page).to have_content 'Comment ça va ?'
    end
  end

  describe 'index' do
    let!(:question) do
      create :question_glisser_deposer
    end
    let!(:transcription) do
      create :transcription, question_id: question.id, ecrit: 'Comment ça va ?'
    end

    before(:each) { visit admin_questions_glisser_deposer_path }

    it do
      expect(page).to have_content 'Comment ça va ?'
    end
  end

  describe 'création' do
    before(:each) do
      visit new_admin_question_glisser_deposer_path
    end

    context 'sans transcriptions' do
      before(:each) do
        fill_in :question_glisser_deposer_libelle, with: 'Question'
        fill_in :question_glisser_deposer_nom_technique, with: 'question'
      end

      it 'créé une nouvelle question' do
        expect { click_on 'Créer' }.to(change { Question.count })
        expect(Question.first.transcriptions).to be_empty
      end
    end

    context 'quand une transcription pour intitule est ajouté' do
      before(:each) do
        fill_in :question_glisser_deposer_libelle, with: 'Question'
        fill_in :question_glisser_deposer_nom_technique, with: 'question'
        fill_in :question_glisser_deposer_transcriptions_attributes_0_ecrit, with: 'Intitulé'
        click_on 'Créer'
      end

      it do
        expect(Question.first.transcriptions.count).to eq 1
        expect(Question.first.transcription_intitule&.ecrit).to eq 'Intitulé'
      end
    end

    context 'quand une transcription pour modalité réponse est ajoutée' do
      before(:each) do
        fill_in :question_glisser_deposer_libelle, with: 'Question'
        fill_in :question_glisser_deposer_nom_technique, with: 'question'
        fill_in :question_glisser_deposer_transcriptions_attributes_1_ecrit, with: 'Consigne'
        click_on 'Créer'
      end

      it do
        expect(Question.first.transcriptions.count).to eq 1
        expect(Question.first.transcription_modalite_reponse&.ecrit).to eq 'Consigne'
      end
    end

    context 'quand une illustration est ajoutée' do
      before(:each) do
        fill_in :question_glisser_deposer_libelle, with: 'Question'
        fill_in :question_glisser_deposer_nom_technique, with: 'question'
        attach_file(:question_glisser_deposer_illustration,
                    Rails.root.join('spec/support/programme_tele.png'))
        click_on 'Créer'
      end

      it do
        expect(Question.first.illustration.attached?).to eq true
      end
    end
  end

  describe 'modification' do
    let!(:question) do
      create :question_glisser_deposer,
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

    context "quand l'admin supprime l'écrit d'une transcription et qu'il n'y a pas d'audio" do
      before(:each) do
        visit edit_admin_question_glisser_deposer_path(question)
        fill_in :question_glisser_deposer_transcriptions_attributes_0_ecrit, with: nil
      end

      it 'supprime la transcription' do
        expect(Question.first.transcriptions.count).to eq 2
        click_on 'Enregistrer'
        expect(Question.first.transcriptions.count).to eq 1
      end
    end

    context "quand l'admin coche supprimer l'illustration" do
      before(:each) do
        visit edit_admin_question_glisser_deposer_path(question)
        check 'question_glisser_deposer_supprimer_illustration'
      end

      it "supprime l'illustration" do
        expect(question.illustration.attached?).to eq true
        click_on 'Enregistrer'
        question.reload
        expect(question.illustration.attached?).to eq false
      end
    end

    context "quand l'admin coche supprimer l'audio de l'intitulé" do
      before(:each) do
        Question.first.transcriptions.find_by(categorie: :intitule)
                .update(audio: Rack::Test::UploadedFile.new(
                  Rails.root.join('spec/support/alcoolique.mp3')
                ))
        visit edit_admin_question_glisser_deposer_path(question)
        check 'question_glisser_deposer_supprimer_audio_intitule'
      end

      it "supprime l'audio" do
        expect(
          Question.first.transcriptions.find_by(categorie: :intitule).audio.attached?
        ).to eq true
        click_on 'Enregistrer'
        question.reload
        expect(
          Question.first.transcriptions.find_by(categorie: :intitule).audio.attached?
        ).to eq false
      end
    end

    context "quand l'admin coche supprimer l'audio de la consigne" do
      before(:each) do
        Question.first.transcriptions.find_by(categorie: :modalite_reponse)
                .update(audio: Rack::Test::UploadedFile.new(
                  Rails.root.join('spec/support/alcoolique.mp3')
                ))
        visit edit_admin_question_glisser_deposer_path(question)
        check 'question_glisser_deposer_supprimer_audio_modalite_reponse'
      end

      it "supprime l'audio" do
        expect(
          Question.first.transcriptions.find_by(categorie: :modalite_reponse).audio.attached?
        ).to eq true
        click_on 'Enregistrer'
        question.reload
        expect(
          Question.first.transcriptions.find_by(categorie: :modalite_reponse).audio.attached?
        ).to eq false
      end
    end
  end
end
