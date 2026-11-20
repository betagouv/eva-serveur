require "rails_helper"

describe Filtres::RechercheComponent, type: :component do
  def rendu(valeur: nil, libelle_valeur: nil)
    render_inline(described_class.new(champ: :campagne_id_eq, libelle: "Campagne",
                                      url: "/admin/campagnes.json",
                                      champs_recherche: %i[libelle code],
                                      valeur: valeur, libelle_valeur: libelle_valeur))
  end

  it "transmet l'identifiant choisi dans le prédicat ransack" do
    rendu(valeur: "12", libelle_valeur: "Paris 2019")

    expect(page).to have_field("q[campagne_id_eq]", type: :hidden, with: "12")
  end

  it "décrit la recherche pour le script d'autocomplétion" do
    rendu(valeur: "12", libelle_valeur: "Paris 2019")

    conteneur = page.find("[data-filtre-recherche]")
    expect(conteneur["data-url"]).to eq "/admin/campagnes.json"
    expect(conteneur["data-predicat"]).to eq "libelle_or_code_i_cont"
    expect(conteneur["data-libelle-valeur"]).to eq "Paris 2019"
    expect(page).to have_css("label.fr-label[for='q_campagne_id_eq_recherche']", text: "Campagne")
  end

  it "laisse le champ vide sans valeur choisie" do
    rendu

    expect(page).to have_field("q[campagne_id_eq]", type: :hidden, with: "")
  end
end
