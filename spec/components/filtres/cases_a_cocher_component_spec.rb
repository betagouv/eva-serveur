require "rails_helper"

describe Filtres::CasesACocherComponent, type: :component do
  before do
    render_inline(described_class.new(champ: :statut_in, libelle: "Statut",
                                      options: [ [ "Ouvert", "ouvert" ], [ "Fermé", "ferme" ] ],
                                      valeurs: [ "ferme" ]))
  end

  it "regroupe les cases sous une légende" do
    expect(page).to have_css("fieldset.fr-fieldset legend.fr-fieldset__legend", text: "Statut")
  end

  it "envoie chaque valeur cochée dans le prédicat ransack" do
    expect(page).to have_field("Ouvert", type: "checkbox", with: "ouvert", checked: false)
    expect(page).to have_field("Fermé", type: "checkbox", with: "ferme", checked: true)
    expect(page).to have_css("input[name='q[statut_in][]']", count: 2)
  end

  it "donne un tag par valeur cochée" do
    composant = described_class.new(champ: :statut_in, libelle: "Statut",
                                    options: [ [ "Ouvert", "ouvert" ], [ "Fermé", "ferme" ] ],
                                    valeurs: [ "ferme" ])

    expect(composant.tags.map(&:to_h))
      .to eq [ { libelle: "Fermé", nom: "q[statut_in][]", valeur: "ferme" } ]
  end
end
