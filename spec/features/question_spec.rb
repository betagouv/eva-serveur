# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Question', type: :feature do
  before { se_connecter_comme_administrateur }
  let!(:question) { create :question, intitule: 'Comment ça va ?' }

  describe 'index' do
    before { visit admin_questions_path }
    it do
      expect(page).to have_content 'Comment ça va ?'
    end
  end

  describe 'création' do
    before do
      visit new_admin_question_path
      fill_in :question_intitule, with: '2 + 2 = ?'
    end

    it do
      expect { click_on 'Créer' }.to(change { Question.count })
    end
  end
end
