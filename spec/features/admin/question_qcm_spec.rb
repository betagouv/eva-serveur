# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Question QCM', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'index' do
    let!(:question) do
      create :question_qcm, transcription_ecrit: 'Comment ça va ?'
    end

    before { visit admin_question_qcms_path }

    it do
      expect(page).to have_content 'Comment ça va ?'
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
        expect { click_on 'Créer' }.to(change { Question.count })
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
        expect(Question.first.transcription_ecrite_pour(:intitule)).to eq 'Intitulé'
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
        expect(Question.first.transcription_ecrite_pour(:modalite_reponse)).to eq 'Consigne'
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
        expect(Question.first.illustration.attached?).to eq true
      end
    end
  end

  describe 'modification' do
    let!(:question) do
      create :question_qcm, transcription_ecrit: 'Comment ça va ?'
    end

    before do
      visit edit_admin_question_qcm_path(question)
      fill_in :question_qcm_transcriptions_attributes_0_ecrit, with: nil
    end

    it "supprime la transcription si l'admin supprime la valeur et qu'il n'y a pas d'audio" do
      expect(Question.first.transcriptions).to_not be_empty
      click_on 'Enregistrer'
      expect(Question.first.transcriptions).to be_empty
    end
  end
end
