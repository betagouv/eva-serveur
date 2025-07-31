# frozen_string_literal: true

require "rails_helper"

describe BadgeComponent, type: :component do
  subject(:component) do
    described_class.new(
      contenu: contenu,
      class_couleur: class_couleur,
      display_icon: display_icon,
      taille: taille
    )
  end

  let(:contenu) { "Nouveau" }
  let(:class_couleur) { "fr-badge--success" }
  let(:display_icon) { false }
  let(:taille) { nil }

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

  context "quand html_class est vide" do
    let(:class_couleur) { "" }

    it "rend un badge sans la classe spécifique" do
      render_inline(component)

      expect(page).to have_css(".fr-badge.fr-badge--no-icon")
      expect(page).not_to have_css(".fr-badge--success")
    end
  end
end
