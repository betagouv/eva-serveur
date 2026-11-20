require "rails_helper"

describe FiltresComponent, type: :component do
  def rendu(parametres_conserves: {}, avec_recherche: true, actifs_suivi: 2)
    render_inline(described_class.new(url: "/admin/beneficiaires", id: "filtres",
                                      parametres_conserves: parametres_conserves)) do |filtres|
      if avec_recherche
        filtres.with_recherche(champ: :recherche, libelle: "Nom ou code", valeur: "ali")
      end
      filtres.with_filtre(titre: "Suivi", actifs: actifs_suivi) { "champ suivi" }
      filtres.with_filtre(titre: "Créé le") { "champ dates" }
    end
  end

  it "envoie la recherche et les filtres en GET vers la liste" do
    rendu

    titre = I18n.t("components.filtres.titre")
    expect(page).to have_css("form#filtres[method='get'][action='/admin/beneficiaires']")
    expect(page).to have_css("form[role='search'][aria-label='#{titre}']")
    expect(page).not_to have_field("authenticity_token", type: :hidden)
    expect(page).to have_field("q[recherche]", with: "ali")
  end

  it "conserve les paramètres demandés, comme le tri" do
    rendu(parametres_conserves: { order: "nom_asc", vide: nil })

    expect(page).to have_field("order", type: :hidden, with: "nom_asc")
    expect(page).not_to have_field("vide", type: :hidden)
  end

  describe "menus déroulants" do
    before { rendu }

    it "propose un bouton par filtre, qui déplie son menu avec le mécanisme du DSFR" do
      %w[filtres-filtre-0 filtres-filtre-1].each do |id|
        bouton = page.find("button[aria-controls='#{id}']")
        expect(bouton[:"aria-expanded"]).to eq "false"
        expect(page).to have_css(".filtres__menu ##{id}.fr-collapse.filtres__panneau")
      end
      expect(page.find("button[aria-controls='filtres-filtre-1']")).to have_text("Créé le")
    end

    it "présente les filtres en boutons tertiaires d'un groupe de boutons DSFR" do
      expect(page).to have_css(
        "ul.fr-btns-group.fr-btns-group--inline-sm > li.filtres__menu > " \
        "button.fr-btn.fr-btn--tertiary[aria-controls='filtres-filtre-1']"
      )
    end

    it "met en avant un filtre actif en bouton secondaire, les autres restant tertiaires" do
      expect(page).to have_css("button.fr-btn--secondary[aria-controls='filtres-filtre-0']")
      expect(page).not_to have_css("button.fr-btn--tertiary[aria-controls='filtres-filtre-0']")
      expect(page).to have_css("button.fr-btn--tertiary[aria-controls='filtres-filtre-1']")
    end

    it "indique le nombre de valeurs choisies sur le bouton du filtre" do
      expect(page.find("button[aria-controls='filtres-filtre-0'] .fr-badge")).to have_text("2")
      expect(page).not_to have_css("button[aria-controls='filtres-filtre-1'] .fr-badge")
    end

    it "laisse les menus à bouton Appliquer sans application immédiate" do
      expect(page).not_to have_css("[data-application-immediate]")
    end

    it "affiche le contenu de chaque filtre dans son menu, avec un bouton pour l'appliquer" do
      within("#filtres-filtre-0") do
        expect(page).to have_text("champ suivi")
        expect(page).to have_button(I18n.t("components.filtres.appliquer"), type: "submit")
      end
      expect(page.find_by_id("filtres-filtre-1")).to have_text("champ dates")
    end
  end

  describe "menu à choix unique appliqué dès le choix" do
    def rendu_choix_unique(valeur:)
      render_inline(described_class.new(url: "/admin/beneficiaires", id: "filtres")) do |filtres|
        filtres.with_filtre(titre: "Campagne", valeur: valeur,
                            application_immediate: true) { "champ campagne" }
      end
    end

    it "affiche la valeur choisie sur le bouton plutôt qu'un compteur" do
      rendu_choix_unique(valeur: "Paris 2025")

      bouton = page.find("button[aria-controls='filtres-filtre-0']")
      expect(bouton).to have_text(I18n.t("components.filtres.titre_avec_valeur",
                                         titre: "Campagne", valeur: "Paris 2025"))
      expect(bouton).not_to have_css(".fr-badge")
    end

    it "n'affiche que le titre sans valeur choisie" do
      rendu_choix_unique(valeur: nil)

      expect(page.find("button[aria-controls='filtres-filtre-0']").text.squish).to eq "Campagne"
    end

    it "compte comme un filtre actif à effacer" do
      rendu_choix_unique(valeur: "Paris 2025")

      expect(page).to have_link(I18n.t("components.filtres.effacer"))
    end

    it "indique au menu d'appliquer le filtre dès le choix" do
      rendu_choix_unique(valeur: nil)

      expect(page).to have_css("#filtres-filtre-0[data-application-immediate]")
    end

    it "ne propose pas de bouton Appliquer" do
      rendu_choix_unique(valeur: nil)

      within("#filtres-filtre-0") do
        expect(page).to have_text("champ campagne")
        expect(page).not_to have_button(I18n.t("components.filtres.appliquer"))
      end
    end
  end

  describe "effacement des filtres" do
    it "efface les filtres en gardant la recherche et les paramètres conservés" do
      rendu

      expect(page).to have_link(I18n.t("components.filtres.effacer"),
                                href: "/admin/beneficiaires?q%5Brecherche%5D=ali")
    end

    it "revient à la liste seule sans recherche" do
      rendu(avec_recherche: false)

      expect(page).to have_link(I18n.t("components.filtres.effacer"),
                                href: "/admin/beneficiaires")
    end

    it "est un bouton tertiaire sans bordure, actualisé avec les résultats" do
      rendu

      expect(page).to have_css("#filtres-effacer[data-actualise-a-la-volee] " \
                               "a.fr-btn--tertiary-no-outline",
                               text: I18n.t("components.filtres.effacer"))
    end

    it "n'est pas proposé sans filtre actif" do
      rendu(actifs_suivi: 0)

      expect(page).not_to have_link(I18n.t("components.filtres.effacer"))
    end
  end
end
