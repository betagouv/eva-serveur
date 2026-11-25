require "rails_helper"

describe FiltresComponent, type: :component do
  def suivi(valeurs)
    Filtres::CasesACocherComponent.new(champ: :statut_in, libelle: "Suivi",
                                       options: [ [ "Ouvert", "ouvert" ], [ "Fermé", "ferme" ] ],
                                       valeurs: valeurs)
  end

  def dates
    Filtres::PeriodeComponent.new(champ: :created_at, libelle: "Créé le")
  end

  def rendu(parametres_conserves: {}, avec_recherche: true, valeurs_suivi: %w[ouvert ferme])
    render_inline(described_class.new(url: "/admin/beneficiaires", id: "filtres",
                                      parametres_conserves: parametres_conserves)) do |filtres|
      if avec_recherche
        filtres.with_recherche(champ: :recherche, libelle: "Nom ou code", valeur: "ali")
      end
      filtres.with_filtre(titre: "Suivi", filtres: [ suivi(valeurs_suivi) ])
      filtres.with_filtre(titre: "Créé le", filtres: [ dates ]) { "aide des dates" }
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

  it "place la recherche sous les filtres et leurs tags, au-dessus du tableau" do
    with_request_url("/admin/beneficiaires?q[statut_in][]=ouvert") { rendu }

    blocs = page.all("form#filtres > [id]").map { _1[:id] }
    expect(blocs).to eq %w[filtres-menus filtres-tags filtres-recherche]
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

    it "affiche les champs de chaque filtre dans son menu, avec un bouton pour l'appliquer" do
      within("#filtres-filtre-0") do
        expect(page).to have_field("Ouvert", type: "checkbox", visible: :all)
        expect(page).to have_button(I18n.t("components.filtres.appliquer"), type: "submit")
      end
      within("#filtres-filtre-1") do
        expect(page).to have_field("q[created_at_gteq_datetime]", visible: :all)
        expect(page).to have_text("aide des dates")
      end
    end
  end

  describe "menu appliqué dès le choix" do
    def rendu_choix_unique
      campagne = Filtres::RechercheComponent.new(champ: :campagne_id_eq, libelle: "Campagne",
                                                 url: "/admin/campagnes.json",
                                                 champs_recherche: %i[libelle])
      render_inline(described_class.new(url: "/admin/beneficiaires", id: "filtres")) do |filtres|
        filtres.with_filtre(titre: "Campagne", filtres: [ campagne ], application_immediate: true)
      end
    end

    before { rendu_choix_unique }

    it "indique au menu d'appliquer le filtre dès le choix" do
      expect(page).to have_css("#filtres-filtre-0[data-application-immediate]")
    end

    it "ne propose pas de bouton Appliquer" do
      within("#filtres-filtre-0") do
        expect(page).not_to have_button(I18n.t("components.filtres.appliquer"))
      end
    end
  end

  describe "tags des filtres actifs" do
    before do
      with_request_url("/admin/beneficiaires?q[statut_in][]=ouvert&q[statut_in][]=ferme" \
                       "&q[recherche]=ali&order=nom_asc&page=3") { rendu }
    end

    it "affiche un tag de retrait par valeur choisie, actualisé avec les résultats" do
      within("#filtres-tags[data-actualise-a-la-volee] ul.fr-tags-group") do
        %w[Ouvert Fermé].each do |libelle|
          expect(page).to have_link(libelle, class: %w[fr-tag fr-tag--sm fr-tag--dismiss])
        end
      end
    end

    it "nomme l'action de chaque tag pour les lecteurs d'écran" do
      expect(page.find_link("Ouvert")[:title])
        .to eq I18n.t("components.filtres.retirer", libelle: "Ouvert")
    end

    it "relance la liste sans la valeur du tag, en gardant le reste sauf la page" do
      parametres = { order: "nom_asc", q: { recherche: "ali", statut_in: [ "ferme" ] } }

      expect(page.find_link("Ouvert")[:href])
        .to eq "/admin/beneficiaires?#{parametres.to_query}"
    end
  end

  it "n'affiche pas de tags sans filtre actif" do
    rendu(valeurs_suivi: [])

    expect(page).to have_css("#filtres-tags[data-actualise-a-la-volee]")
    expect(page).not_to have_css(".fr-tags-group")
  end
end
