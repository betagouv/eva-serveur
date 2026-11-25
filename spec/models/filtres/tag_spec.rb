require "rails_helper"

describe Filtres::Tag do
  let(:parametres) do
    { "q" => { "statut_in" => %w[ouvert ferme], "nom_eq" => "Paris" },
      "scope" => "illettrisme_potentiel", "order" => "nom_asc", "page" => "2" }
  end

  it "retire une valeur d'un prédicat à plusieurs valeurs" do
    reste = described_class.new(libelle: "Ouvert", nom: "q[statut_in][]", valeur: "ouvert")
                           .retire_de(parametres)

    expect(reste["q"]).to eq("statut_in" => %w[ferme], "nom_eq" => "Paris")
  end

  it "retire le prédicat quand sa dernière valeur l'est" do
    reste = described_class.new(libelle: "Paris", nom: "q[nom_eq]", valeur: "Paris")
                           .retire_de(parametres)

    expect(reste["q"]).to eq("statut_in" => %w[ouvert ferme])
  end

  it "retire un paramètre hors de q, en gardant les autres sauf la page" do
    reste = described_class.new(libelle: "Illettrisme", nom: "scope",
                                valeur: "illettrisme_potentiel").retire_de(parametres)

    expect(reste).not_to have_key("scope")
    expect(reste).not_to have_key("page")
    expect(reste["order"]).to eq "nom_asc"
  end

  it "ne modifie pas les paramètres reçus" do
    described_class.new(libelle: "Paris", nom: "q[nom_eq]", valeur: "Paris").retire_de(parametres)

    expect(parametres["q"]).to have_key("nom_eq")
  end
end
