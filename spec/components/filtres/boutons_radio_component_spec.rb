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
end
