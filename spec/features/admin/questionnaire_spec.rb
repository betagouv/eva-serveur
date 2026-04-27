require 'rails_helper'

describe 'Admin - Questionnaire', type: :feature do
  before { se_connecter_comme_superadmin }

  describe 'index' do
    let!(:questionnaire) { create :questionnaire, libelle: 'Numératie et Litératie' }

    before { visit admin_questionnaires_path }

    it { expect(page).to have_content 'Numératie et Litératie' }

    context "avec filtre par question" do
      let(:question_associee) { create(:question_saisie, libelle: "Question filtre") }
      let!(:questionnaire_filtre) do
        create(:questionnaire, libelle: "Questionnaire filtré", questions: [ question_associee ])
      end
      let!(:questionnaire_hors_filtre) {
 create(:questionnaire, libelle: "Questionnaire non filtré") }

      it "charge l'index sans erreur 500 et applique le filtre" do
        visit admin_questionnaires_path(q: { questions_id_eq: question_associee.id })

        expect(page).to have_content("Questionnaire filtré")
        expect(page).not_to have_content("Questionnaire non filtré")
      end
    end
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
end
