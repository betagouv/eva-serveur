require "rails_helper"

describe TagDsfrComponent, type: :component do
  it "affiche un tag non cliquable par défaut" do
    render_inline(described_class.new(libelle: "Freins périphériques"))

    expect(page).to have_css("p.fr-tag", text: "Freins périphériques")
    expect(page).to have_no_css("button")
  end

  it "affiche un tag cliquable sous forme de bouton" do
    render_inline(described_class.new(libelle: "Freins périphériques", cliquable: true))

    expect(page).to have_css("button.fr-tag[type='button']", text: "Freins périphériques")
  end

  it "affiche un petit tag" do
    render_inline(described_class.new(libelle: "Freins périphériques", taille: :sm))

    expect(page).to have_css(".fr-tag.fr-tag--sm")
  end

  it "affiche une icône à gauche" do
    render_inline(described_class.new(libelle: "Freins périphériques",
                                      icone: "fr-icon-arrow-right-line"))

    expect(page).to have_css(".fr-tag.fr-icon-arrow-right-line.fr-tag--icon-left")
  end

  it "transmet les attributs HTML" do
    render_inline(described_class.new(libelle: "Freins périphériques", cliquable: true,
                                      class: "choix", data: { qualification: "freins" }))

    expect(page).to have_css("button.fr-tag.choix[data-qualification='freins']")
  end
end
