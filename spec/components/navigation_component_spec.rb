require "rails_helper"

RSpec.describe NavigationComponent, type: :component do
  subject(:component) { described_class.new(current_compte: compte) }

  context "quand le compte est accepté" do
    let(:compte) { create(:compte_conseiller, :acceptee, :structure_avec_admin) }

    it "affiche les liens de navigation accessibles" do
      render_inline(component)

      expect(page).to have_link("Tableau de bord", href: "/admin")
      expect(page).to have_link("Actualités")
      expect(page).to have_link("Évaluations")
      expect(page).to have_link("Comptes")
      expect(page).to have_link("Aide")
    end
  end

  context "quand le compte est en attente et restreint" do
    let(:compte) do
      create(
        :compte_conseiller,
        :en_attente,
        :structure_avec_admin,
        etape_inscription: "nouveau",
        exempte_restriction_acces_attente: false
      )
    end

    it "n'affiche que les liens autorisés par l'ability" do
      render_inline(component)

      expect(page).to have_link("Tableau de bord", href: "/admin")
      expect(page).to have_link("Aide")
      expect(page).to have_link("Actualités")
      expect(page).not_to have_link("Évaluations")
      expect(page).not_to have_link("Comptes")
    end
  end

  context "quand le compte est charge_mission_regionale" do
    let(:compte) { create(:compte_charge_mission_regionale, :acceptee, :structure_avec_admin) }

    it "n'affiche pas le lien Aide (lecture SourceAide interdite)" do
      render_inline(component)

      expect(page).to have_link("Tableau de bord", href: "/admin")
      expect(page).not_to have_link("Aide")
    end
  end

  context "quand le compte est superadmin" do
    let(:compte) { create(:compte_superadmin, :acceptee, :structure_avec_admin) }

    it "affiche la navigation EVA complète avec les groupes déroulants" do
      render_inline(component)

      expect(page).to have_link("Tableau de bord", href: "/admin")
      expect(page).to have_link("Actualités")
      expect(page).to have_link("Campagnes")
      expect(page).to have_link("Évaluations")
      expect(page).to have_link("Bénéficiaires")

      expect(page).to have_button("Accompagnement")
      expect(page).to have_link("Sources d'aide", visible: :all)
      expect(page).to have_link("Annonces générales", visible: :all)

      expect(page).to have_button("Parcours")
      expect(page).to have_link("Parcours", visible: :all)
      expect(page).to have_link("Questionnaires", visible: :all)
      expect(page).to have_link("Questions QCM", visible: :all)
      expect(page).to have_link("Questions clic dans image", visible: :all)
      expect(page).to have_link("Questions clic dans texte", visible: :all)
      expect(page).to have_link("Questions glisser déposer", visible: :all)
      expect(page).to have_link("Questions saisie", visible: :all)
      expect(page).to have_link("Questions sous consigne", visible: :all)
      expect(page).to have_link("Situations", visible: :all)

      expect(page).to have_button("Structures")
      expect(page).to have_link("Structures locales", visible: :all)
      expect(page).to have_link("Structures administratives", visible: :all)
      expect(page).to have_link("Opcos", visible: :all)
    end
  end
end
