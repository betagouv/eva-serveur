require "rails_helper"

describe TagComponent, type: :component do
  it "affiche un tag non cliquable par défaut" do
    render_inline(described_class.new(libelle: "Martin"))

    expect(page).to have_css("p.fr-tag", text: "Martin")
    expect(page).to have_no_css("button")
  end

  it "affiche un tag cliquable sous forme de bouton" do
    render_inline(described_class.new(libelle: "Martin", cliquable: true))

    expect(page).to have_css("button.fr-tag[type='button']", text: "Martin")
  end

  context "quand une taille est spécifiée" do
    it "ajoute la classe de taille au tag statique" do
      render_inline(described_class.new(libelle: "Martin", taille: :sm))

      expect(page).to have_css("p.fr-tag.fr-tag--sm")
    end

    it "ajoute la classe de taille au tag supprimable" do
      render_inline(described_class.new(libelle: "Martin", supprimable: true, url: "/retirer",
                                        taille: :sm))

      expect(page).to have_css("button.fr-tag.fr-tag--dismiss.fr-tag--sm")
    end
  end

  it "affiche une icône à gauche" do
    render_inline(described_class.new(libelle: "Martin", icone: "fr-icon-arrow-right-line"))

    expect(page).to have_css(".fr-tag.fr-icon-arrow-right-line.fr-tag--icon-left")
  end

  it "transmet les attributs HTML" do
    render_inline(described_class.new(libelle: "Martin", cliquable: true,
                                      class: "choix", data: { qualification: "freins" }))

    expect(page).to have_css("button.fr-tag.choix[data-qualification='freins']")
  end

  context "quand le tag est supprimable" do
    it "rend un bouton DSFR de suppression qui envoie un PATCH vers l'url" do
      render_inline(described_class.new(libelle: "Martin", supprimable: true, url: "/retirer"))

      expect(page).to have_css("form[action='/retirer'] input[name='_method'][value='patch']",
                               visible: :all)
      expect(page).to have_button(
        "Martin", class: %w[fr-tag fr-tag--dismiss],
                  exact_text: true
      )
      expect(page).to have_css(
        "button[aria-label='#{I18n.t('tag.retirer', contenu: 'Martin')}']"
      )
    end
  end
end
