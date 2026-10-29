require "rails_helper"

describe Tag, type: :component do
  context "quand le tag n'est pas supprimable" do
    it "rend un tag DSFR statique" do
      render_inline(described_class.new("Martin"))

      expect(page).to have_css("p.fr-tag", text: "Martin")
      expect(page).not_to have_button
    end
  end

  context "quand une taille est spécifiée" do
    it "ajoute la classe de taille au tag statique" do
      render_inline(described_class.new("Martin", taille: "sm"))

      expect(page).to have_css("p.fr-tag.fr-tag--sm")
    end

    it "ajoute la classe de taille au tag supprimable" do
      render_inline(described_class.new("Martin", supprimable: true, url: "/retirer", taille: "sm"))

      expect(page).to have_css("button.fr-tag.fr-tag--dismiss.fr-tag--sm")
    end
  end

  context "quand le tag est supprimable" do
    it "rend un bouton DSFR de suppression qui envoie un PATCH vers l'url" do
      render_inline(described_class.new("Martin", supprimable: true, url: "/retirer"))

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
