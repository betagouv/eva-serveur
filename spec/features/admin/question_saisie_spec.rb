require 'rails_helper'

describe 'Admin - Question Saisie', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'index' do
    let!(:question) do
      create :question_saisie
    end

    before { visit admin_questions_saisies_path }

    it "affiche le bouton d'import" do
      expect(page).to have_link(
        'Importer questions saisies',
        href: admin_import_xls_path(
          type: QuestionSaisie::QUESTION_TYPE,
          model: 'question',
          redirect_to: admin_questions_saisies_path
        )
      )
    end
  end

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
