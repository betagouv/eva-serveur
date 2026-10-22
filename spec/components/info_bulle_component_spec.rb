require "rails_helper"

describe InfoBulleComponent, type: :component do
  subject(:component) { described_class.new(texte: "Pas de suivi") }

  it "affiche le déclencheur, focusable au clavier" do
    render_inline(component) { "-" }

    expect(page).to have_css("span[tabindex='0']", text: "-")
  end

  it "relie le déclencheur à l'info-bulle DSFR" do
    render_inline(component) { "-" }

    id_info_bulle = page.find("span.fr-tooltip.fr-placement[role='tooltip']", visible: :all)[:id]
    expect(page).to have_css("span[tabindex='0'][aria-describedby='#{id_info_bulle}']")
  end

  it "affiche le texte de l'info-bulle" do
    render_inline(component) { "-" }

    expect(page).to have_css(".fr-tooltip", text: "Pas de suivi", visible: :all)
  end
end
