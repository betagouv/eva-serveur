# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Questionnaire', type: :feature do
  before { se_connecter_comme_administrateur }
  let!(:questionnaire) { create :questionnaire, libelle: 'Numératie et Litératie' }

  describe 'index' do
    before { visit admin_questionnaires_path }
    it do
      expect(page).to have_content 'Numératie et Litératie'
    end
  end

  describe 'création' do
    before do
      visit new_admin_questionnaire_path
      fill_in :questionnaire_libelle, with: 'Evaluation Formation'
      fill_in :questionnaire_questions, with: "[{q: 'question1'}]"
    end

    it do
      expect { click_on 'Créer' }.to(change { Questionnaire.count })
      expect(page).to have_content "[{q: 'question1'}]"
    end
  end
end
