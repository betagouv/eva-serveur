require "rails_helper"

describe ResultatComponent, type: :component do
  let(:interpretations) { "activerecord.attributes.evaluation_eva.interpretations" }

  it "affiche le domaine, le séparateur et le titre" do
    render_inline(described_class.new(domaine: :litteratie, niveau: "profil1"))

    expect(page).to have_css(".resultat__domaine", text: I18n.t("resultat.domaines.litteratie"))
    expect(page).to have_css(".resultat__separateur", text: "-")
    expect(page).to have_css(".resultat__titre", text: I18n.t("resultat.titres.profil1"))
  end

  it "peut afficher le résultat sans titre" do
    render_inline(described_class.new(domaine: :litteratie, niveau: "profil1", avec_titre: false))

    expect(page).to have_css(".resultat__domaine", text: I18n.t("resultat.domaines.litteratie"))
    expect(page).to have_no_css(".resultat__separateur")
    expect(page).to have_no_css(".resultat__titre")
  end

  it "affiche le badge de profil d'eva pour la littératie et la numératie" do
    allow(Badge::ProfilComponent).to receive(:new).and_call_original

    render_inline(described_class.new(domaine: :numeratie, niveau: "profil3"))

    expect(Badge::ProfilComponent).to have_received(:new).with("profil3", :numeratie)
  end

  it "affiche en orange un niveau pré-A1 ou pré-X1" do
    render_inline(described_class.new(domaine: :francais, niveau: "pre_A1"))

    expect(page).to have_css(".fr-badge.fr-badge--sm.fr-badge--orange-terre-battue",
                             text: I18n.t("#{interpretations}.niveau_cefr.pre_A1"))
  end

  it "affiche en bleu un niveau A1, A2, X1 ou X2" do
    render_inline(described_class.new(domaine: :mathematiques, niveau: "X2"))

    expect(page).to have_css(".fr-badge.fr-badge--blue-cumulus",
                             text: I18n.t("#{interpretations}.niveau_cnef.X2"))
  end

  it "affiche en vert un niveau B1+ ou Y1+" do
    render_inline(described_class.new(domaine: :francais, niveau: "B1"))

    expect(page).to have_css(".fr-badge.fr-badge--green-emeraude",
                             text: I18n.t("#{interpretations}.niveau_cefr.B1"))
  end

  context "quand le score n'est pas calculé" do
    it "affiche un badge gris « ? » et « Score non calculé » pour un niveau" do
      render_inline(described_class.new(domaine: :francais, niveau: nil))

      expect(page).to have_css(".fr-badge.fr-badge--grey-950",
                               text: I18n.t("resultat.badges.non_calcule"))
      expect(page).to have_css(".resultat__titre", text: I18n.t("resultat.titres.non_calcule"))
    end

    it "affiche « Score non calculé » pour un profil absent" do
      render_inline(described_class.new(domaine: :litteratie, niveau: nil))

      expect(page).to have_css(".resultat__titre",
                               exact_text: I18n.t("resultat.titres.non_calcule"))
    end

    it "affiche « Non testé » pour un profil aberrant, indéterminé ou absent" do
      allow(Badge::ProfilComponent).to receive(:new).and_call_original

      [ "profil_aberrant", "indetermine", nil ].each do |niveau|
        render_inline(described_class.new(domaine: :litteratie, niveau: niveau))
      end

      expect(Badge::ProfilComponent).to have_received(:new).with(nil, :litteratie).exactly(3).times
    end

    it "affiche « Score non calculé » pour un profil aberrant" do
      render_inline(described_class.new(domaine: :litteratie, niveau: "profil_aberrant"))

      expect(page).to have_css(".resultat__titre", text: I18n.t("resultat.titres.non_calcule"))
    end
  end
end
