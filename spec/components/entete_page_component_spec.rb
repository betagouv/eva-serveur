require "rails_helper"

describe EntetePageComponent, type: :component do
  def rendu(&)
    render_inline(described_class.new(titre: "Bénéficiaires",
                                      fil_ariane: [ { libelle: "Accueil", lien: "/admin" },
                                                    { libelle: "Bénéficiaires" } ]), &)
  end

  it "affiche le titre de la page" do
    rendu

    expect(page).to have_css("h1", text: "Bénéficiaires")
  end

  it "affiche le fil d'Ariane du DSFR, la page courante sans lien" do
    rendu

    expect(page).to have_css("nav.fr-breadcrumb a.fr-breadcrumb__link[href='/admin']",
                             text: "Accueil")
    expect(page).to have_css("a.fr-breadcrumb__link[aria-current]:not([href])",
                             text: "Bénéficiaires")
  end

  it "affiche la description fournie sous le titre" do
    rendu { |entete| entete.with_description { "Entreprise ANLCI" } }

    expect(page).to have_css("h1 + p", text: "Entreprise ANLCI")
  end

  it "affiche les actions et la barre fournies" do
    rendu do |entete|
      entete.with_actions { "Nouveau" }
      entete.with_barre { "Recherche" }
    end

    expect(page).to have_text("Nouveau")
    expect(page).to have_text("Recherche")
  end

  it "n'affiche ni actions ni barre si elles ne sont pas fournies" do
    rendu

    expect(page).not_to have_css(".entete-page__actions")
    expect(page).not_to have_css(".entete-page__barre")
  end
end
