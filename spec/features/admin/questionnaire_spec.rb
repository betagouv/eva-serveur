# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Questionnaire', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'index' do
    let!(:questionnaire) { create :questionnaire, libelle: 'Numératie et Litératie' }

    before { visit admin_questionnaires_path }

    it { expect(page).to have_content 'Numératie et Litératie' }
  end

  describe 'création' do
    before do
      visit new_admin_questionnaire_path
      fill_in :questionnaire_libelle, with: 'Evaluation Formation'
      fill_in :questionnaire_nom_technique, with: 'evaluation_formation'
    end

    it do
      expect { click_on 'Créer' }.to(change(Questionnaire, :count))
      expect(page).to have_content 'Evaluation Formation'
    end
  end

  describe 'import' do
    it 'importe un fichier XLS' do
      visit new_import_xls_admin_questionnaires_path

      chemin_fichier = Rails.root.join('spec/support/import_questionnaire.xls').to_s
      attach_file('file_xls', chemin_fichier)
      click_button 'Importer le fichier'

      expect(page).to have_http_status(200)
      expect(Questionnaire.count).to eq(1)
    end
  end
end
