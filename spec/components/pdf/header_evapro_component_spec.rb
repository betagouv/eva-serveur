require "rails_helper"

describe Pdf::HeaderEvaproComponent, type: :component do
  let(:structure) { build(:structure_locale, nom: "Grand hôpital") }
  let(:date) { Time.zone.local(2026, 2, 11, 14, 42) }

  it "affiche par défaut la structure et la personne évaluée" do
    render_inline(described_class.new(date: date, beneficiaire: "Martin Dupont",
                                      structure: structure))

    expect(page).to have_content("Grand hôpital")
    expect(page).to have_content("Martin Dupont")
  end

  it "n'affiche que les logos sans détails" do
    render_inline(described_class.new(date: date, beneficiaire: "Martin Dupont",
                                      structure: structure, avec_details: false))

    expect(page).to have_css(".fr-header__logo")
    expect(page).to have_no_content("Grand hôpital")
    expect(page).to have_no_content("Martin Dupont")
  end
end
