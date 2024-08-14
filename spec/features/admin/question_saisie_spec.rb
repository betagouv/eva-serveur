# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Question Saisie', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'création' do
    before do
      visit new_admin_question_saisie_path
    end

    context 'quand un type saisie est ajouté' do
      before do
        fill_in :question_saisie_libelle, with: 'Question'
        fill_in :question_saisie_nom_technique, with: 'question'
        select 'Numerique', from: :question_saisie_type_saisie
        click_on 'Créer'
      end

      it do
        expect(Question.first.type_saisie).to eq 'numerique'
      end
    end
  end
end
