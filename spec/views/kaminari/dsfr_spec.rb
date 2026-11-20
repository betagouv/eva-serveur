require "rails_helper"

describe "Thème de pagination Kaminari « dsfr »", type: :helper do
  def pagination(page:, total: 95)
    collection = Kaminari.paginate_array((1..total).to_a).page(page).per(10)
    Capybara.string(
      helper.paginate(collection, theme: "dsfr",
                                  params: { controller: "admin/beneficiaires", action: "index" })
    )
  end

  it "n'affiche rien quand tout tient sur une page" do
    expect(pagination(page: 1, total: 5).text).to be_blank
  end

  context "sur la première page" do
    subject(:rendu) { pagination(page: 1) }

    it "affiche la pagination DSFR" do
      titre = I18n.t("pagination_dsfr.titre")
      expect(rendu).to have_css("nav.fr-pagination[aria-label='#{titre}'] ul.fr-pagination__list")
    end

    it "désactive les liens vers la première page et la page précédente" do
      %w[first prev].each do |lien|
        expect(rendu).to have_css(
          "a.fr-pagination__link--#{lien}[aria-disabled='true'][role='link']:not([href])"
        )
      end
    end

    it "indique la page courante" do
      expect(rendu).to have_css("a.fr-pagination__link[aria-current='page']:not([href])", text: "1")
    end

    it "permet d'aller à la page suivante et à la dernière" do
      expect(rendu).to have_link(I18n.t("pagination_dsfr.suivante"),
                                 href: "/admin/beneficiaires?page=2")
      expect(rendu).to have_link(I18n.t("pagination_dsfr.derniere"),
                                 href: "/admin/beneficiaires?page=10")
    end

    it "remplace les pages masquées par des points de suspension" do
      expect(rendu).to have_css("li", text: "…")
    end
  end

  context "sur la dernière page" do
    subject(:rendu) { pagination(page: 10) }

    it "désactive les liens vers la page suivante et la dernière page" do
      %w[next last].each do |lien|
        expect(rendu).to have_css(
          "a.fr-pagination__link--#{lien}[aria-disabled='true']:not([href])"
        )
      end
    end

    it "permet de revenir à la première page" do
      expect(rendu).to have_link(I18n.t("pagination_dsfr.premiere"), href: "/admin/beneficiaires")
    end
  end
end
