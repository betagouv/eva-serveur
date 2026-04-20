# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Inscription - Informations du compte", type: :request do
  let(:compte) {
 create(:compte, email: "conseiller@example.fr", etape_inscription: "preinscription") }

  describe "PATCH /inscription/informations_compte" do
    context "quand le compte est connecte" do
      before { sign_in(compte) }

      it "enregistre les champs du formulaire et redirige vers la recherche de structure" do
        patch inscription_informations_compte_path, params: {
          compte: {
            nom: "Dupont",
            prenom: "Jean",
            email: "conseiller@example.fr",
            telephone: "06 06 06 06 06",
            service_departement: "Service insertion",
            fonction: "autre",
            cgu_acceptees: true
          }
        }

        expect(response).to redirect_to(inscription_recherche_structure_path)

        compte.reload
        expect(compte.nom).to eq("Dupont")
        expect(compte.prenom).to eq("Jean")
        expect(compte.email).to eq("conseiller@example.fr")
        expect(compte.telephone).to eq("06 06 06 06 06")
        expect(compte.service_departement).to eq("Service insertion")
        expect(compte.fonction).to eq("autre")
        expect(compte.cgu_acceptees).to be(true)
        expect(compte.etape_inscription).to eq("recherche_structure")
      end
    end
  end
end
