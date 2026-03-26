require "rails_helper"

RSpec.describe HeaderComponent, type: :component do
  it "affiche le logo opérateur EVA fourni au composant" do
    compte = create(:compte_superadmin, :acceptee, :structure_avec_admin)

    render_inline(
      described_class.new(
        logo: "logo/eva-bleu.svg",
        logo_alt: "EVA",
        current_compte: compte,
        actions: []
      )
    )

    expect(page).to have_css("img.fr-responsive-img[alt='EVA']")
  end
end
