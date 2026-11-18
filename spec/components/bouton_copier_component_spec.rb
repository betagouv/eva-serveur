require "rails_helper"

describe BoutonCopierComponent, type: :component do
  subject(:component) do
    described_class.new(libelle: libelle, texte: texte, classes: classes, **options)
  end

  let(:libelle) { "Copier" }
  let(:texte) { "texte à copier" }
  let(:classes) { "" }
  let(:options) { {} }

  it "rend un bouton avec la classe copier-coller, data-clipboard-text et le libellé attendus" do
    render_inline(component)

    expect(page).to have_css("button.copier-coller")
    expect(page).to have_css("button[data-clipboard-text='#{texte}']")
    expect(page).to have_content(libelle)
  end

  it "rend un bouton tertiaire, conformément au DSFR pour une action de copie" do
    render_inline(component)

    expect(page).to have_css("button.fr-btn.fr-btn--tertiary")
    expect(page).to have_no_css("button.fr-btn--secondary")
  end

  context "quand des classes supplémentaires sont passées" do
    let(:classes) { "ma-classe" }

    it "inclut les classes supplémentaires" do
      render_inline(component)

      expect(page).to have_css("button.copier-coller.ma-classe")
    end
  end
end
