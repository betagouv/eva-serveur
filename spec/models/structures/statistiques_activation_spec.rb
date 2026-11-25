require "rails_helper"

describe Structures::StatistiquesActivation do
  let(:activation) { class_double(Structures::Activation) }
  let(:liste) { instance_double(ActiveRecord::Relation) }
  let(:liste_filtree) { instance_double(ActiveRecord::Relation) }

  it "laisse la liste telle quelle hors des statistiques" do
    statistiques = described_class.new(activation, actif: false, statut: "actives")

    expect(statistiques.applique(liste)).to be liste
    expect(statistiques.statut).to be_nil
  end

  it "restreint la liste au statut choisi en statistiques" do
    allow(activation).to receive(:filtre).with(liste, "actives").and_return(liste_filtree)
    statistiques = described_class.new(activation, actif: true, statut: "actives")

    expect(statistiques.applique(liste)).to be liste_filtree
    expect(statistiques.statut).to eq "actives"
  end

  it "compte chaque statut sur la liste d'avant le choix du statut" do
    allow(activation).to receive(:filtre).and_return(liste_filtree)
    allow(activation).to receive(:nombres).with(liste).and_return("actives" => 2)
    statistiques = described_class.new(activation, actif: true, statut: "actives")
    statistiques.applique(liste)

    expect(statistiques.nombres).to eq("actives" => 2)
  end
end
