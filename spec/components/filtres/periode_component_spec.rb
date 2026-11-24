require "rails_helper"

describe Filtres::PeriodeComponent, type: :component do
  before do
    render_inline(described_class.new(champ: :created_at, libelle: "Créé le",
                                      debut: "2025-01-01", fin: nil))
  end

  it "regroupe les deux dates sous une légende" do
    expect(page).to have_css("fieldset.fr-fieldset legend", text: "Créé le")
  end

  it "envoie les bornes dans les prédicats de dates d'ActiveAdmin" do
    expect(page).to have_field(I18n.t("admin.date_depuis"), type: "date", with: "2025-01-01")
    expect(page).to have_field("q[created_at_gteq_datetime]", type: "date")
    expect(page).to have_field(I18n.t("admin.date_jusqua"), type: "date")
    expect(page).to have_field("q[created_at_lteq_datetime]", type: "date")
  end

  it "donne un tag par borne renseignée" do
    composant = described_class.new(champ: :created_at, libelle: "Créé le",
                                    debut: "2025-01-31", fin: nil)

    libelle = I18n.t("components.filtres.tag_debut", libelle: "Créé le",
                                                     date: I18n.l(Date.new(2025, 1, 31)))
    expect(composant.tags.map(&:to_h)).to eq [
      { libelle: libelle,
        nom: "q[created_at_gteq_datetime]", valeur: "2025-01-31" }
    ]
  end
end
