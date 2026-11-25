require "rails_helper"

describe Filtres::BoutonsRadioComponent, type: :component do
  before do
    render_inline(described_class.new(nom: :activation, libelle: "Activation",
                                      options: [ [ "Actives (3)", "actives" ],
                                                 [ "Inactives (1)", "inactives" ] ],
                                      valeur: "inactives"))
  end

  it "regroupe les choix sous une légende" do
    expect(page).to have_css("fieldset.fr-fieldset legend", text: "Activation")
  end

  it "propose un choix pour ne rien filtrer, puis chaque option, sous le nom demandé" do
    expect(page).to have_field(I18n.t("components.filtres.toutes"), type: "radio", with: "",
                                                                     checked: false)
    expect(page).to have_field("Actives (3)", type: "radio", with: "actives", checked: false)
    expect(page).to have_field("Inactives (1)", type: "radio", with: "inactives", checked: true)
    expect(page).to have_css("input[type='radio'][name='activation']", count: 3)
  end

  it "donne un tag pour le choix fait, aucun pour Toutes" do
    options = [ [ "Actives (3)", "actives" ] ]

    expect(described_class.new(nom: :activation, libelle: "Activation", options: options,
                               valeur: "actives").tags.map(&:to_h))
      .to eq [ { libelle: "Actives (3)", nom: "activation", valeur: "actives" } ]
    expect(described_class.new(nom: :activation, libelle: "Activation", options: options,
                               valeur: "").tags).to be_empty
  end

  it "relie chaque libellé à son choix, même pour un nom de prédicat ransack" do
    render_inline(described_class.new(nom: "q[statut_eq]", libelle: "Statut",
                                      options: [ [ "À suivre", "0" ] ]))

    page.all("input[type='radio']").each do |choix|
      expect(page).to have_css("label[for='#{choix[:id]}']")
    end
    expect(page).to have_field("À suivre", type: "radio")
  end
end
