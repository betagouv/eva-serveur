require "rails_helper"

describe Filtres::BarreRechercheComponent, type: :component do
  before do
    render_inline(described_class.new(champ: :recherche, libelle: "Nom ou code", valeur: "ALI"))
  end

  it "affiche la barre de recherche du DSFR" do
    expect(page).to have_css(".fr-search-bar label.fr-label[for='q_recherche']",
                             text: "Nom ou code")
    expect(page).to have_field("q[recherche]", type: "search", with: "ALI", class: "fr-input")
  end

  it "filtre à la volée, sans bouton de recherche" do
    expect(page).to have_css("input[data-recherche-a-la-volee]")
    expect(page).not_to have_button
  end
end
