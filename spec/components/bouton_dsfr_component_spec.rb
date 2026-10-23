require "rails_helper"

describe BoutonDsfrComponent, type: :component do
  it "rend un bouton tertiaire sans contour" do
    render_inline(described_class.new("/cible", type: :tertiary_no_outline, size: :sm)) do
      "Libellé"
    end

    expect(page).to have_css("a.fr-btn.fr-btn--tertiary-no-outline.fr-btn--sm[href='/cible']",
                             text: "Libellé")
  end
end
