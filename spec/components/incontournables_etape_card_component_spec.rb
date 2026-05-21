# frozen_string_literal: true

require "rails_helper"

describe IncontournablesEtapeCardComponent, type: :component do
  subject(:component) do
    described_class.new(
      numero: "01",
      titre: "Je m’informe",
      image_path: "incontournables/jinforme 1.svg",
      couleur_texte: "#3272AD",
      couleur_fond: "#DCE2E7",
      image_alt: "Illustration étape"
    )
  end

  it "rend la carte avec variables de couleur et le texte En savoir plus" do
    render_inline(component)

    expect(page).to have_css(
      ".incontournables-card[style*='--incontournables-card-bg: #DCE2E7']"
    )
    expect(page).to have_css(
      ".incontournables-card[style*='--incontournables-card-color: #3272AD']"
    )
    expect(page).to have_css(
      ".incontournables-card__en-savoir-plus-texte",
      text: I18n.t("admin.evaluations.aller_plus_loin.etapes.en_savoir_plus")
    )
  end
end
