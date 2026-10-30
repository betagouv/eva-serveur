require "rails_helper"

describe ResultatComponent, type: :component do
  it "affiche la pastille, le domaine et le titre" do
    render_inline(described_class.new(domaine: :litteratie, niveau: "profil1"))

    expect(page).to have_css(".resultat__pastille", text: I18n.t("resultat.pastilles.profil1"))
    expect(page).to have_css(".resultat__domaine", text: I18n.t("resultat.domaines.litteratie"))
    expect(page).to have_css(".resultat__titre", text: I18n.t("resultat.titres.profil1"))
  end

  it "affiche en orange un profil 1 ou 2 et un niveau pré-A1 ou pré-X1" do
    render_inline(described_class.new(domaine: :litteratie, niveau: "profil2"))
    expect(page).to have_css(".resultat__pastille--alerte")

    render_inline(described_class.new(domaine: :francais, niveau: "pre_A1"))
    expect(page).to have_css(".resultat__pastille--alerte")
  end

  it "affiche en bleu un profil 3 et un niveau A1, A2, X1 ou X2" do
    render_inline(described_class.new(domaine: :numeratie, niveau: "profil3"))
    expect(page).to have_css(".resultat__pastille--intermediaire")

    render_inline(described_class.new(domaine: :mathematiques, niveau: "X2"))
    expect(page).to have_css(".resultat__pastille--intermediaire")
  end

  it "affiche en vert un profil 4 et plus, B1+ ou Y1+" do
    render_inline(described_class.new(domaine: :litteratie, niveau: "profil_4h_plus_plus"))
    expect(page).to have_css(".resultat__pastille--succes")

    render_inline(described_class.new(domaine: :francais, niveau: "B1"))
    expect(page).to have_css(".resultat__pastille--succes")
  end

  it "affiche une pastille ronde pour un profil, rectangulaire pour un niveau" do
    render_inline(described_class.new(domaine: :litteratie, niveau: "profil1"))
    expect(page).to have_css(".resultat__pastille--ronde")

    render_inline(described_class.new(domaine: :francais, niveau: "A1"))
    expect(page).not_to have_css(".resultat__pastille--ronde")
  end

  context "quand le score n'est pas calculé" do
    it "affiche une pastille grise « ? » et « Score non calculé »" do
      render_inline(described_class.new(domaine: :litteratie, niveau: "profil_aberrant"))

      expect(page).to have_css(".resultat__pastille--desactive",
                               text: I18n.t("resultat.pastilles.non_calcule"))
      expect(page).to have_css(".resultat__titre", text: I18n.t("resultat.titres.non_calcule"))
    end

    it "traite de la même façon un niveau absent" do
      render_inline(described_class.new(domaine: :francais, niveau: nil))

      expect(page).to have_css(".resultat__pastille--desactive")
    end
  end
end
