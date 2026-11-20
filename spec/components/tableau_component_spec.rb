require "rails_helper"

describe TableauComponent, type: :component do
  let(:ligne) { Data.define(:id, :nom) }
  let(:collection) { [ ligne.new(id: 12, nom: "Alice"), ligne.new(id: 34, nom: "Bob") ] }

  def rendu(**options, &bloc)
    render_inline(described_class.new(collection: collection, **options)) do |tableau|
      tableau.colonne(titre: "Nom", &:nom)
      bloc&.call(tableau)
    end
  end

  it "affiche une ligne par élément de la collection" do
    rendu

    expect(page).to have_css("tbody tr", count: 2)
    expect(page).to have_css("tbody tr[data-id='12'] td", text: "Alice")
  end

  it "utilise l'identifiant fourni pour éviter les doublons sur une même page" do
    rendu(id: "liste")

    expect(page).to have_css("div.fr-table#liste-component table#liste")
  end

  describe "sélection des lignes" do
    before do
      with_request_url("/admin/beneficiaires") do
        rendu(selectionnable: true, champ_selection: "ids[]", ids_selectionnes: [ "34" ])
      end
    end

    it "transmet l'identifiant de chaque ligne cochée dans le champ demandé" do
      expect(page).to have_field("ids[]", type: "checkbox", with: "12", checked: false)
      expect(page).to have_field("ids[]", type: "checkbox", with: "34", checked: true)
    end

    it "laisse le DSFR marquer les lignes sélectionnées" do
      expect(page).to have_css("input[data-fr-row-select='true']", count: 2)
    end

    it "nomme la case d'après la ligne pour les lecteurs d'écran" do
      expect(page).to have_css("label.fr-label",
                               text: I18n.t("components.tableau.selectionner_ligne", numero: 1))
    end
  end

  describe "tri" do
    def rendu_triable(ordre:)
      with_request_url("/admin/beneficiaires?q[nom_cont]=a&page=3") do
        rendu(ordre: ordre) do |tableau|
          tableau.colonne(titre: "Créé le", tri: "created_at") { "" }
        end
      end
    end

    it "propose de trier une colonne non triée, par ordre décroissant d'abord" do
      rendu_triable(ordre: "nom_asc")

      lien = page.find("th a.fr-btn--sort")
      expect(lien[:href]).to eq "/admin/beneficiaires?order=created_at_desc&q%5Bnom_cont%5D=a"
      expect(page).not_to have_css("th[aria-sort]")
    end

    it "indique le sens du tri courant et propose de l'inverser" do
      rendu_triable(ordre: "created_at_desc")

      expect(page).to have_css("th[aria-sort='descending'] a.fr-btn--sort-desc")
      expect(page.find("th a.fr-btn--sort-desc")[:href]).to include("order=created_at_asc")
    end

    it "indique le tri croissant" do
      rendu_triable(ordre: "created_at_asc")

      expect(page).to have_css("th[aria-sort='ascending'] a.fr-btn--sort-asc")
    end

    it "garde le titre des colonnes non triables en texte" do
      rendu_triable(ordre: "created_at_asc")

      expect(page).not_to have_css("th a", text: "Nom")
    end
  end

  it "affiche l'en-tête et le pied de tableau fournis" do
    render_inline(described_class.new(collection: collection)) do |tableau|
      tableau.with_entete { "Actions groupées" }
      tableau.with_pied { "Pagination" }
      tableau.colonne(titre: "Nom", &:nom)
    end

    expect(page).to have_css(".fr-table > .fr-table__header", text: "Actions groupées")
    expect(page).to have_css(".fr-table > .fr-table__footer", text: "Pagination")
  end
end
