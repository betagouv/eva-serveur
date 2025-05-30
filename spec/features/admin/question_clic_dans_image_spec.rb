# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Question Clic dans Image', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'show' do
    let!(:question) do
      create :question_clic_dans_image, libelle: 'Libellé de la question'
    end
    let!(:transcription) do
      create :transcription, question_id: question.id, ecrit: 'Comment ça va ?'
    end

    before { visit admin_question_clic_dans_image_path(question) }

    it 'affiche le libellé de la question' do
      expect(page).to have_content 'Libellé de la question'
    end

    it 'affiche la transcription associée' do
      expect(page).to have_content 'Comment ça va ?'
    end

    it "affiche le bouton d'export" do
      expect(page).to have_link 'Exporter la question en XLS'
      find(
        "#action_items_sidebar_section a[href='#{admin_question_export_xls_path(
          question_id: question.id
        )}']"
      ).click
      expect(page.response_headers['Content-Type']).to eq 'application/vnd.ms-excel'
    end
  end

  describe 'index' do
    let!(:question) do
      create :question_clic_dans_image
    end
    let!(:transcription) do
      create :transcription, question_id: question.id, ecrit: 'Comment ça va ?'
    end

    before { visit admin_questions_clic_dans_image_path }

    it do
      expect(page).to have_content 'Comment ça va ?'
    end

    it "affiche le bouton d'import" do
      expect(page).to have_link(
        'Importer questions clic dans image',
        href: admin_import_xls_path(
          type: QuestionClicDansImage::QUESTION_TYPE,
          model: 'question',
          redirect_to: admin_questions_clic_dans_image_path
        )
      )
    end
  end

  describe 'création' do
    before do
      visit new_admin_question_clic_dans_image_path
    end

    context 'sans transcriptions' do
      before do
        fill_in :question_clic_dans_image_libelle, with: 'Question'
        fill_in :question_clic_dans_image_nom_technique, with: 'question'
      end

      it 'créé une nouvelle question' do
        expect { click_on 'Créer' }.to(change(Question, :count))
        expect(Question.first.transcriptions).to be_empty
      end
    end

    context 'quand une transcription pour intitule est ajouté' do
      before do
        fill_in :question_clic_dans_image_libelle, with: 'Question'
        fill_in :question_clic_dans_image_nom_technique, with: 'question'
        fill_in :question_clic_dans_image_transcriptions_attributes_0_ecrit, with: 'Intitulé'
        click_on 'Créer'
      end

      it do
        expect(Question.first.transcriptions.count).to eq 1
        expect(Question.first.transcription_intitule&.ecrit).to eq 'Intitulé'
      end
    end

    context 'quand une transcription pour modalité réponse est ajoutée' do
      before do
        fill_in :question_clic_dans_image_libelle, with: 'Question'
        fill_in :question_clic_dans_image_nom_technique, with: 'question'
        fill_in :question_clic_dans_image_transcriptions_attributes_1_ecrit, with: 'Consigne'
        click_on 'Créer'
      end

      it do
        expect(Question.first.transcriptions.count).to eq 1
        expect(Question.first.transcription_modalite_reponse&.ecrit).to eq 'Consigne'
      end
    end

    context 'quand une illustration est ajoutée' do
      before do
        fill_in :question_clic_dans_image_libelle, with: 'Question'
        fill_in :question_clic_dans_image_nom_technique, with: 'question'
        attach_file(:question_clic_dans_image_illustration,
                    Rails.root.join('spec/support/programme_tele.png'))
        click_on 'Créer'
      end

      it do
        expect(Question.first.illustration.attached?).to be true
      end
    end

    context 'quand une zone cliquable est ajoutée' do
      context 'avec la classe css bonne-reponse' do
        before do
          fill_in :question_clic_dans_image_libelle, with: 'Question'
          fill_in :question_clic_dans_image_nom_technique, with: 'question'
          attach_file(:question_clic_dans_image_zone_cliquable,
                      Rails.root.join('spec/support/accessibilite-avec-reponse.svg'))
          click_on 'Créer'
        end

        it do
          question = Question.first
          expect(question.zone_cliquable.attached?).to be true
          expect(question.errors[:zone_cliquable]).to be_empty
        end
      end

      context 'sans la classe css bonne-reponse' do
        before do
          fill_in :question_clic_dans_image_libelle, with: 'Question'
          fill_in :question_clic_dans_image_nom_technique, with: 'question'
          attach_file(:question_clic_dans_image_zone_cliquable,
                      Rails.root.join('spec/support/accessibilite-sans-reponse.svg'))
          click_on 'Créer'
        end

        it do
          expect(page).to have_content(
            "doit contenir la classe '#{QuestionClicDansImage::CLASS_BONNE_REPONSE}'"
          )
          expect(Question.count).to eq(0)
        end
      end
    end
  end

  describe 'modification' do
    let!(:question) do
      create :question_clic_dans_image,
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
      before do
        visit edit_admin_question_clic_dans_image_path(question)
        fill_in :question_clic_dans_image_transcriptions_attributes_0_ecrit, with: nil
      end

      it 'supprime la transcription' do
        expect(Question.first.transcriptions.count).to eq 2
        click_on 'Enregistrer'
        expect(Question.first.transcriptions.count).to eq 1
      end
    end

    context "quand l'admin coche supprimer l'illustration" do
      before do
        visit edit_admin_question_clic_dans_image_path(question)
        check 'question_clic_dans_image_supprimer_illustration'
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
        visit edit_admin_question_clic_dans_image_path(question)
        check 'question_clic_dans_image_supprimer_audio_intitule'
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

    context "quand l'admin coche supprimer l'audio de la consigne" do
      before do
        Question.first.transcriptions.find_by(categorie: :modalite_reponse)
                .update(audio: Rack::Test::UploadedFile.new(
                  Rails.root.join('spec/support/alcoolique.mp3')
                ))
        visit edit_admin_question_clic_dans_image_path(question)
        check 'question_clic_dans_image_supprimer_audio_modalite_reponse'
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
  end
end
