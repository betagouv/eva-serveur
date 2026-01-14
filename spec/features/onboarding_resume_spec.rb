require "rails_helper"

describe "Reprise d'onboarding après reconnexion", type: :feature do
  let!(:compte) do
    create(
      :compte,
      email: "resume@example.test",
      password: "Password78901$",
      structure: nil,
      role: :conseiller,
      statut_validation: :en_attente,
      etape_inscription: :recherche_structure,
      siret_pro_connect: "13002526500013",
      cgu_acceptees: true
    )
  end

  it "redirige vers l'étape en cours après connexion" do
    connecte_email email: compte.email, password: "Password78901$"

    expect(page).to have_current_path(inscription_recherche_structure_path)
  end
end
