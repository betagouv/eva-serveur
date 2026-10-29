require "rails_helper"

describe BadgeComponent, type: :component do
  subject(:component) do
    described_class.new(
      contenu: contenu,
      class_couleur: class_couleur,
      display_icon: display_icon,
      taille: taille,
      classes: classes
    )
  end

  let(:contenu) { "Nouveau" }
  let(:class_couleur) { "fr-badge--success" }
  let(:display_icon) { false }
  let(:taille) { nil }
  let(:classes) { nil }

  it "rend correctement le badge avec ses classes par défaut" do
    render_inline(component)

    expect(page).to have_css(".fr-badge.fr-badge--success.fr-badge--no-icon")
    expect(page).to have_content(contenu)
  end

  context "quand display_icon est true" do
    let(:display_icon) { true }

    it "ne met pas la classe fr-badge--no-icon" do
      render_inline(component)

      expect(page).to have_css(".fr-badge.fr-badge--success")
      expect(page).not_to have_css(".fr-badge--no-icon")
    end
  end

  context "quand une taille est spécifiée" do
    let(:taille) { "sm" }

    it "ajoute la classe correspondant à la taille" do
      render_inline(component)

      expect(page).to have_css(".fr-badge.fr-badge--success.fr-badge--no-icon.fr-badge--sm")
    end
  end

  context "quand des classes supplémentaires sont spécifiées" do
    let(:classes) { "fr-ml-1v hidden" }

    it "les ajoute au badge" do
      render_inline(component)

      expect(page).to have_css(".fr-badge.fr-badge--success.fr-ml-1v.hidden", visible: :all)
    end
  end

  context "quand aucune couleur n'est spécifiée" do
    it "rend un badge gris par défaut (pas de class spécifique)" do
      render_inline(described_class.new(contenu: contenu))

      expect(page).to have_css(".fr-badge.fr-badge--no-icon", text: contenu)
    end
  end
end
