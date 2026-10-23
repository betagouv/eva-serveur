require 'rails_helper'

describe 'Admin - Bénéficiaires', type: :feature do
  describe 'show' do
    context "quand le conseiller n'a pas accès" do
      let!(:conseiller) { create :compte_conseiller, :structure_avec_admin }
      let!(:autre_conseiller) { create :compte_conseiller, :structure_avec_admin }
      let!(:beneficiaire) { create :beneficiaire }
      let!(:campagne_visible) {
        create :campagne, :avec_parcours_positionnement, compte: conseiller }
      let!(:autre_campagne) {
        create :campagne, :avec_parcours_positionnement, compte: autre_conseiller }
      let!(:evaluation_visible) do
        create(
          :evaluation,
          :eva,
          beneficiaire: beneficiaire,
          campagne: campagne_visible
        )
      end
      let!(:evaluation_non_visible) do
        create(:evaluation, :eva, :positionnement, beneficiaire: beneficiaire,
          campagne: autre_campagne)
      end

      before { connecte(conseiller) }

      it "le conseiller voit uniquement les évaluations auxquelles il a accès" do
        Bullet.enable = false if defined?(Bullet)

        visit admin_beneficiaire_path(beneficiaire)

        expect(page).to have_css("[data-id='#{evaluation_visible.id}']")
        expect(page).not_to have_css("[data-id='#{evaluation_non_visible.id}']")

        Bullet.enable = true if defined?(Bullet)
      end
    end
  end

  describe "index" do
    context "en tant qu'admin" do
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

    context "colonne Suivi" do
      let!(:compte_admin) { create :compte_admin }
      let(:campagne) { create :campagne, compte: compte_admin }

      before do
        create :evaluation, :eva, campagne: campagne
        connecte(compte_admin)
      end

      it "affiche la colonne Suivi entre le code bénéficiaire et la date de création" do
        visit admin_beneficiaires_path

        entetes = all("thead th").map(&:text)
        expect(entetes.index("Suivi")).to eq entetes.index("Code bénéficiaire") + 1
        expect(entetes.index("Créé le")).to eq entetes.index("Suivi") + 1
      end
    end
  end
end
