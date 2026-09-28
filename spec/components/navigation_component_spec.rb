require "rails_helper"

RSpec.describe NavigationComponent, type: :component do
  subject(:component) { described_class.new(current_compte: compte) }

  context "quand le compte est accepté" do
    let(:compte) { create(:compte_conseiller, :acceptee, :structure_avec_admin) }

    it "affiche les liens de navigation accessibles" do
      render_inline(component)

      expect(page).to have_link("Tableau de bord", href: "/admin")
      expect(page).to have_link("Actualités")
      expect(page).to have_link("Évaluations", href: "/admin/evaluations_eva")
      expect(page).not_to have_link("Evapro", visible: :all)
      expect(page).to have_link("Comptes")
      expect(page).to have_link("Aide")
      expect(page).not_to have_button("Référentiels")
      expect(page).not_to have_link("Sources d'aide", visible: :all)
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
      expect(page).not_to have_link("Sources d'aide", visible: :all)
      expect(page).not_to have_button("Référentiels")
      expect(page).not_to have_link("Évaluations")
      expect(page).not_to have_link("Comptes")
      expect(page).not_to have_link("Campagnes")
      expect(page).not_to have_link("Bénéficiaires")
      expect(page).not_to have_link("Annonces générales", visible: :all)
      expect(page).not_to have_button("Structures")
    end
  end

  context "quand le compte est charge_mission_regionale" do
    let(:compte) { create(:compte_charge_mission_regionale, :acceptee, :structure_avec_admin) }

    it "affiche le lien Aide mais pas le menu Référentiels" do
      render_inline(component)

      expect(page).to have_link("Tableau de bord", href: "/admin")
      expect(page).to have_link("Aide")
      expect(page).not_to have_button("Référentiels")
      expect(page).not_to have_link("Sources d'aide", visible: :all)
    end
  end

  context "quand le compte est superadmin" do
    let(:compte) { create(:compte_superadmin, :acceptee, :structure_avec_admin) }

    context "affiche la navigation EVA complète avec les groupes déroulants" do
      before { render_inline(component) }

      it "affiche les liens de navigation principaux" do
        expect(page).to have_link("Tableau de bord", href: "/admin")
        expect(page).to have_link("Actualités")
        expect(page).to have_link("Campagnes")
        expect(page).to have_button("Évaluations")
        expect(page).to have_link("Eva", visible: :all)
        expect(page).to have_link("Evapro", visible: :all)
        expect(page).to have_link("Bénéficiaires")
      end

      it "regroupe accompagnement et parcours dans le menu Référentiels, après Structures" do
        expect(page).not_to have_button("Accompagnement")
        expect(page).not_to have_button("Parcours")
        expect(page.all("button.fr-nav__btn").map { |bouton| bouton[:"aria-controls"] })
          .to eq(%w[header-menu-evaluations header-menu-structures header-menu-referentiels])
      end

      it "affiche le menu Référentiels sous forme de roue crantée avec un nom accessible" do
        bouton = page.find("button.fr-nav__btn[aria-controls='header-menu-referentiels']")
        expect(bouton[:title]).to eq("Référentiels")
        expect(bouton).to have_css(".fr-icon-settings-5-line[aria-hidden='true']")
        expect(bouton).to have_css(".fr-nav__btn-libelle", text: "Référentiels")
      end

      it "affiche les liens d'accompagnement puis de parcours dans le menu Référentiels" do
        menu = page.find("#header-menu-referentiels", visible: :all)
        expect(menu.all("a", visible: :all).map { |lien| lien.text(:all).strip }).to eq(
          [
            "Annonces générales",
            "Opérateurs de compétences",
            "Parcours type",
            "Questionnaires",
            "Questions QCM",
            "Questions clic dans image",
            "Questions clic dans texte",
            "Questions glisser déposer",
            "Questions saisie",
            "Questions sous consigne",
            "Situations",
            "Sources d'aide"
          ]
        )
      end

      it "affiche les liens de navigation Structures" do
        expect(page).to have_button("Structures")
        expect(page).to have_link("Structures locales", visible: :all)
        expect(page).to have_link("Structures administratives", visible: :all)
        expect(page).to have_link("Structures opérateurs de compétences", visible: :all)
      end
    end
  end

  context "quand le compte est un employé OPCO non admin" do
    let(:structure) { create(:structure_opco, :avec_admin) }
    let(:compte) { create(:compte_conseiller, :acceptee, structure: structure) }

    it "affiche la navigation OPCO avec le lien Comptes" do
      render_inline(component)

      expect(page).to have_link("Tableau de bord", href: "/admin")
      expect(page).to have_link("Actualités")
      expect(page).to have_link("Aide")
      expect(page).to have_link("Comptes")
      expect(page).not_to have_link("Évaluations")
      expect(page).not_to have_link(href: "/admin/evaluations_eva")
      expect(page).not_to have_link(href: "/admin/evaluations_evapro")
      expect(page).not_to have_link("Campagnes")
      expect(page).not_to have_link("Bénéficiaires")
      expect(page).not_to have_button("Référentiels")
      expect(page).not_to have_button("Structures")
    end
  end

  context "quand le compte est un employé OPCO admin" do
    let(:structure) { create(:structure_opco, :avec_admin) }
    let(:compte) { create(:compte_admin, :acceptee, structure: structure) }

    it "affiche le lien Comptes" do
      render_inline(component)

      expect(page).to have_link("Tableau de bord", href: "/admin")
      expect(page).to have_link("Actualités")
      expect(page).to have_link("Aide")
      expect(page).to have_link("Comptes")
      expect(page).not_to have_link("Évaluations")
      expect(page).not_to have_link(href: "/admin/evaluations_eva")
      expect(page).not_to have_link(href: "/admin/evaluations_evapro")
      expect(page).not_to have_link("Campagnes")
      expect(page).not_to have_link("Bénéficiaires")
    end
  end

  context "quand le compte est utilisateur entreprise (EvaPro)" do
    let(:structure) { create(:structure_locale, :avec_admin, usage: AvecUsage::USAGE_EVAPRO) }
    let(:compte) { create(:compte_admin, :acceptee, structure: structure) }

    it "n'affiche que le lien Evapro parmi les évaluations" do
      render_inline(component)

      expect(page).to have_link("Évaluations", href: "/admin/evaluations_evapro")
      expect(page).not_to have_link("Eva", visible: :all)
      expect(page).not_to have_link(href: "/admin/evaluations_eva")
      expect(page).not_to have_link("Campagnes")
      expect(page).not_to have_link("Bénéficiaires")
    end
  end

  context "quand la structure n'est pas OPCO" do
    let(:compte) { create(:compte_admin, :acceptee, :structure_avec_admin) }

    it "n'active pas la navigation OPCO" do
      render_inline(component)

      expect(page).to have_link("Comptes")
      expect(page).to have_link("Évaluations", href: "/admin/evaluations_eva")
      expect(page).to have_link("Campagnes")
    end
  end
end
