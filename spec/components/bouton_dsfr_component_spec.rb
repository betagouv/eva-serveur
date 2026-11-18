require "rails_helper"

describe BoutonDsfrComponent, type: :component do
  it "exige un tag explicite" do
    expect { described_class.new("/chemin") }.to raise_error(ArgumentError, /tag/)
  end

  it "refuse un tag inconnu" do
    expect { described_class.new("/chemin", tag: :div) }.to raise_error(/Tag must be one of/)
  end

  it "rend un bouton de navigation avec le tag :a" do
    render_inline(described_class.new("/chemin", tag: :a).with_content("Jouer"))

    expect(page).to have_css("a.fr-btn.fr-btn--primary[href='/chemin']", text: "Jouer")
  end

  it "rend un bouton d'action avec le tag :button" do
    render_inline(described_class.new("#", tag: :button).with_content("Ouvrir"))

    expect(page).to have_css("button.fr-btn[type='button']", text: "Ouvrir")
  end

  it "rend un bouton de téléchargement avec le tag :telechargement" do
    render_inline(described_class.new("/export.pdf", tag: :telechargement, type: :secondary)
                    .with_content("Exporter"))

    expect(page).to have_css("a.fr-btn.fr-btn--secondary.fr-icon-download-line" \
                             ".fr-btn--icon-left[href='/export.pdf'][download]",
                             text: "Exporter")
  end

  it "rend un bouton tertiaire sans contour" do
    render_inline(described_class.new("/cible", tag: :a, type: :tertiary_no_outline, size: :sm)) do
      "Libellé"
    end

    expect(page).to have_css("a.fr-btn.fr-btn--tertiary-no-outline.fr-btn--sm[href='/cible']",
                             text: "Libellé")
  end
end
