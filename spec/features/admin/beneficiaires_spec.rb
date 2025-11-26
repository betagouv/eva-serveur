require 'rails_helper'

describe 'Admin - Bénéficiaires', type: :feature do
  describe 'show' do
    context "quand le bénéficiaire n'a pas accès" do
      let!(:conseiller) { create :compte_conseiller, :structure_avec_admin }
      let!(:beneficiaire) { create :beneficiaire }
      let!(:evaluation_visible) do
        create(
          :evaluation,
          :positionnement,
          beneficiaire: beneficiaire,
          responsable_suivi_id: conseiller.id
        )
      end
      let!(:evaluation_non_visible) do
        create(:evaluation, :positionnement, beneficiaire: beneficiaire)
      end

      before { connecte(conseiller) }

      it "le conseiller voit uniquement les évaluations dont il a accès" do
        visit admin_beneficiaire_path(beneficiaire)

        expect(page).to have_css("[data-id='#{evaluation_visible.id}']")
        expect(page).not_to have_css("[data-id='#{evaluation_non_visible.id}']")
      end
    end
  end

  describe 'index' do
    context 'en tant qu\'admin' do
      let!(:structure) { create :structure_locale, :avec_admin }
      let!(:compte_admin) { create :compte_admin, structure: structure }

      before do
        connecte(compte_admin)
        visit admin_beneficiaires_path
      end

      it "n'affiche pas le bouton 'Nouveau bénéficiaire'" do
        expect(page).not_to have_content("Nouveau bénéficiaire")
        expect(page).not_to have_link("Nouveau bénéficiaire")
      end
    end
  end
end
