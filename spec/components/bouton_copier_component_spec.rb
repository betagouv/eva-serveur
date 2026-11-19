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

  it "rend une infobulle masquée, décrivant le bouton, qui confirme la copie" do
    render_inline(component)

    id_infobulle = page.find("button.copier-coller")["aria-describedby"]
    expect(page).to have_css("##{id_infobulle}.fr-tooltip[role='tooltip'][hidden]",
                             text: I18n.t("actions.copie"), visible: :hidden)
  end

  context "quand un aria-describedby est passé" do
    let(:options) { { aria: { describedby: "libelle-campagne" } } }

    it "le conserve en plus de l'infobulle" do
      render_inline(component)

      ids = page.find("button.copier-coller")["aria-describedby"].split
      expect(ids.first).to eq("libelle-campagne")
      expect(page).to have_css("##{ids.last}.fr-tooltip", visible: :hidden)
    end
  end

  context "quand des classes supplémentaires sont passées" do
    let(:classes) { "ma-classe" }

    it "inclut les classes supplémentaires" do
      render_inline(component)

      expect(page).to have_css("button.copier-coller.ma-classe")
    end
  end
end
