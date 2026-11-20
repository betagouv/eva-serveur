require "rails_helper"

describe Filtres::TexteComponent, type: :component do
  it "affiche un champ texte DSFR nommé selon le prédicat ransack" do
    render_inline(described_class.new(champ: :nom_cont, libelle: "Nom", valeur: "Ali"))

    expect(page).to have_css(".fr-input-group label.fr-label[for='q_nom_cont']", text: "Nom")
    expect(page).to have_field("q[nom_cont]", type: "text", with: "Ali", class: "fr-input")
  end
end
