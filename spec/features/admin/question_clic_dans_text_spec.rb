# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Question Clic dans Texte', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'show' do
    let!(:question) do
      create :question_clic_dans_texte, libelle: 'Libellé de la question',
                                        texte_sur_illustration: '## Texte sur l\'illustration'
    end
    let!(:transcription) do
      create :transcription, question_id: question.id, ecrit: 'Comment ça va ?'
    end

    before { visit admin_question_clic_dans_texte_path(question) }

    it 'affiche le libellé de la question et la transcription associée' do
      expect(page).to have_content 'Libellé de la question'
      expect(page).to have_content 'Comment ça va ?'
      expect(page).to have_content 'Texte sur l\'illustration'
      expect(page).to have_css('h2', text: 'Texte sur l\'illustration')
    end
  end
end
