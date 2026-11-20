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
end
