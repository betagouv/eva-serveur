require 'rails_helper'

describe Admin::BeneficiairesController, type: :controller do
  render_views

  describe "export JSON" do
    let(:structure) { create :structure_locale }
    let!(:compte) { create :compte_admin, structure: structure }
    let!(:campagne) { create :campagne, compte: compte }
    let!(:evaluation) { create :evaluation, campagne: campagne }
    let(:beneficiaire) { evaluation.beneficiaire }

    before do
      beneficiaire.update!(nom: "Dupont", code_beneficiaire: "ABC123")
      sign_in compte
    end

    it "retourne les bénéficiaires au format JSON avec uniquement les champs autorisés" do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to include("application/json")

      resultat = response.parsed_body
      beneficiaire_json = resultat.find { |b| b["id"] == beneficiaire.id }

      expect(beneficiaire_json.keys).to match_array(%w[id nom code_beneficiaire display_name])
      expect(beneficiaire_json["nom"]).to eq("Dupont")
      expect(beneficiaire_json["code_beneficiaire"]).to eq("ABC123")
    end
  end

  describe "filtre par structure" do
    let(:structure) { create :structure_locale }
    let!(:compte) { create :compte_admin, structure: structure }
    let!(:autre_campagne) { create :campagne, compte: compte }
    let!(:campagne) { create :campagne, compte: compte }
    let!(:beneficiaire) { create :beneficiaire }
    let!(:evaluation) { create :evaluation, campagne: campagne, beneficiaire: beneficiaire }
    let!(:autre_evaluation) do
      create :evaluation, campagne: autre_campagne, beneficiaire: beneficiaire
    end

    before { sign_in compte }

    it "ne retourne pas le bénéficiaire en double quand il a plusieurs évaluations par structure" do
      get :index, format: :json,
        params: { q: { evaluations_campagne_compte_structure_id_eq: structure.id } }

      expect(response).to be_successful

      resultat = response.parsed_body
      occurrences = resultat.select { |b| b["id"] == beneficiaire.id }

      expect(occurrences.size).to eq(1)
    end
  end
end
