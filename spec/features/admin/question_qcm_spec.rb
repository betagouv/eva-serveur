# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Question QCM', type: :feature do
  before { se_connecter_comme_superadmin }
  let!(:question) { create :question_qcm, libelle: 'question', intitule: 'Comment ça va ?' }

  describe 'index' do
    before { visit admin_question_qcms_path }
    it do
      expect(page).to have_content 'Comment ça va ?'
    end
  end

  describe 'création' do
    before do
      visit new_admin_question_qcm_path
      fill_in :question_qcm_libelle, with: 'Question'
      fill_in :question_qcm_nom_technique, with: 'question'
      fill_in :question_qcm_intitule, with: '2 + 2 = ?'
    end

    it do
      expect { click_on 'Créer' }.to(change { Question.count })
    end
  end
end
