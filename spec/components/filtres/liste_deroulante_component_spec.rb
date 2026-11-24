require "rails_helper"

describe Filtres::ListeDeroulanteComponent, type: :component do
  before do
    render_inline(described_class.new(champ: :region_eq, libelle: "Région",
                                      options: [ [ "Bretagne", "Bretagne" ], [ "Corse", "Corse" ] ],
                                      valeur: "Corse"))
  end

  it "affiche une liste déroulante DSFR nommée selon le prédicat ransack" do
    expect(page).to have_css(".fr-select-group label.fr-label[for='q_region_eq']", text: "Région")
    expect(page).to have_select("q[region_eq]", selected: "Corse", class: "fr-select")
  end

  it "reste une liste déroulante native du DSFR, sans Select2 d'activeadmin_addons" do
    expect(page).to have_css("select.fr-select.default-select")
  end

  it "propose de ne rien filtrer" do
    toutes = I18n.t("components.filtres.toutes")
    expect(page).to have_select("q[region_eq]", options: [ toutes, "Bretagne", "Corse" ])
  end

  it "donne un tag pour l'option choisie" do
    composant = described_class.new(champ: :region_eq, libelle: "Région",
                                    options: [ [ "Bretagne", "BZH" ] ], valeur: "BZH")

    expect(composant.tags.map(&:to_h))
      .to eq [ { libelle: "Bretagne", nom: "q[region_eq]", valeur: "BZH" } ]
  end

  it "accepte des options réduites à leur valeur" do
    composant = described_class.new(champ: :region_eq, libelle: "Région",
                                    options: %w[Bretagne Corse], valeur: "Corse")

    expect(composant.tags.map(&:libelle)).to eq [ "Corse" ]
  end
end
