# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Question Sous Consigne', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'index' do
    let!(:question) do
      create :question_sous_consigne
    end
    let!(:transcription) do
      create :transcription, question_id: question.id, ecrit: 'Intitulé sous consigne'
    end

    before { visit admin_question_sous_consignes_path }

    it do
      expect(page).to have_content 'Intitulé sous consigne'
    end

    it "affiche le bouton d'import" do
      expect(page).to have_link(
        'Importer questions sous consigne',
        href: admin_import_xls_path(
          type: QuestionSousConsigne::QUESTION_TYPE,
          model: 'question',
          redirect_to: admin_question_sous_consignes_path
        )
      )
    end
  end
end
