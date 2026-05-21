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
      image_alt: "Illustration étape",
      url: url
    )
  end

  let(:url) { "https://www.bao-incontournables.fr/etape-1-informer/" }

  it "rend la carte comme lien externe avec variables de couleur et le texte En savoir plus" do
    render_inline(component)

    expect(page).to have_css(
      "a.incontournables-card[href='#{url}'][target='_blank'][rel='noopener noreferrer']" \
        "[style*='--incontournables-card-bg: #DCE2E7']" \
        "[style*='--incontournables-card-color: #3272AD']"
    )
    expect(page).to have_css(
      ".incontournables-card__en-savoir-plus-texte",
      text: I18n.t("admin.evaluations.aller_plus_loin.etapes.en_savoir_plus")
    )
  end

  context "quand pdf est true" do
    subject(:component) do
      described_class.new(
        numero: "01",
        titre: "Je m’informe",
        image_path: "incontournables/jinforme 1.svg",
        couleur_texte: "#3272AD",
        couleur_fond: "#DCE2E7",
        image_alt: "Illustration étape",
        url: url,
        pdf: true
      )
    end

    it "rend une carte statique compacte sans lien" do
      render_inline(component)

      expect(page).to have_css(
        "div.incontournables-card.incontournables-card--pdf" \
          "[style*='--incontournables-card-bg: #DCE2E7']" \
          "[style*='--incontournables-card-color: #3272AD']"
      )
      expect(page).to have_css(
        ".incontournables-card--pdf__conteneur--textes-numero",
        text: "01"
      )
      expect(page).to have_css(
        ".incontournables-card--pdf__conteneur--textes-titre",
        text: "Je m’informe"
      )
      expect(page).to have_no_css("a.incontournables-card")
      expect(page).to have_no_css(".incontournables-card__en-savoir-plus-texte")
    end
  end
end
