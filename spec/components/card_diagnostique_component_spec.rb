# frozen_string_literal: true

require "rails_helper"

describe CardDiagnostiqueComponent, type: :component do
  let(:titre) { "Titre" }
  let(:bouton_label) { "Lancer" }
  let(:bouton_url) { "https://example.com" }
  let(:texte_75_caracteres) do
    "Personnalisé pour votre secteur d'activité par Constructys. Évaluation plus"
  end

  it "n'ajoute pas de points de suspension quand le texte tient en 75 caractères" do
    component = described_class.new(
      titre: titre,
      description: texte_75_caracteres,
      bouton_label: bouton_label,
      bouton_url: bouton_url
    )

    expect(component.description_affichee).to eq(texte_75_caracteres)
  end

  it "tronque et termine par le caractère … quand le texte dépasse 75 caractères visibles" do
    long = "#{texte_75_caracteres} et la suite ne doit pas apparaître"
    component = described_class.new(
      titre: titre,
      description: long,
      bouton_label: bouton_label,
      bouton_url: bouton_url
    )

    resultat = component.description_affichee
    expect(resultat).to end_with(described_class::OMISSION)
    expect(resultat.length).to eq(described_class::DESCRIPTION_TRUNCATE_AT)
  end
end
