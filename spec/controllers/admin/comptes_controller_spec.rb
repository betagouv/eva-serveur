require 'rails_helper'

describe Admin::ComptesController, type: :controller do
  render_views

  describe "export JSON" do
    let(:structure) { create :structure_locale }
    let!(:compte_connecte) { create :compte_admin, structure: structure }
    let!(:compte) do
      create :compte_conseiller,
             structure: structure,
             email: "jean.dupont@exemple.fr",
             nom: "Dupont",
             prenom: "Jean"
    end

    before do
      sign_in compte_connecte
    end

    it "retourne les comptes au format JSON avec uniquement les champs autorisés" do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to include("application/json")

      resultat = response.parsed_body
      compte_json = resultat.find { |c| c["id"] == compte.id }

      expect(compte_json.keys).to match_array(%w[id email nom prenom display_name])
      expect(compte_json["email"]).to eq("jean.dupont@exemple.fr")
      expect(compte_json["nom"]).to eq("Dupont")
      expect(compte_json["prenom"]).to eq("Jean")
    end
  end

  describe "form structure_id" do
    context "pour un compte de structure locale" do
      let(:structure_locale) { create :structure_locale }
      let(:compte_admin) { create :compte_admin, structure: structure_locale }

      before do
        sign_in compte_admin
      end

      context "lors de la création d'un nouveau compte" do
        before { get :new }

        it "le champ structure_id est caché avec la valeur du compte connecté" do
          expect(response.body).to include("value=\"#{structure_locale.id}\"")
          expect(response.body).to include('type="hidden"')
        end
      end

      context "lors de l'édition d'un compte existant avec une structure différente" do
        let(:structure_fille) do
          create :structure_locale, structure_referente: structure_locale
        end
        let!(:admin_fille) { create :compte_admin, structure: structure_fille }
        let(:compte_existant) { create :compte_conseiller, structure: structure_fille }

        before { get :edit, params: { id: compte_existant.id } }

        it "le champ structure_id préserve la structure du compte édité" do
          expect(response.body).to include("value=\"#{structure_fille.id}\"")
          expect(response.body).not_to include("value=\"#{structure_locale.id}\"")
        end
      end
    end

    context "pour un compte de structure administrative" do
      let(:structure_administrative) { create :structure_administrative }
      let(:compte_admin_administratif) { create :compte_admin, structure: structure_administrative }

      before do
        sign_in compte_admin_administratif
      end

      context "lors de l'édition d'un compte existant sans campagne" do
        let(:structure_locale_fille_1) do
          create :structure_locale, structure_referente: structure_administrative
        end
        let(:structure_locale_fille_2) do
          create :structure_locale, structure_referente: structure_administrative
        end
        let!(:admin_fille_1) { create :compte_admin, structure: structure_locale_fille_1 }
        let!(:admin_fille_2) { create :compte_admin, structure: structure_locale_fille_2 }
        let(:compte_existant) { create :compte_conseiller, structure: structure_locale_fille_1 }

        before { get :edit, params: { id: compte_existant.id } }

        it "le champ structure est éditable avec les structures filles" do
          expect(response.body).to include('id="compte_structure_input"')
          expect(response.body).not_to include('disabled="disabled"')
          expect(response.body).to include(structure_locale_fille_1.nom)
          expect(response.body).to include(structure_locale_fille_2.nom)
        end
      end

      context "lors de l'édition d'un compte existant avec des campagnes" do
        let(:structure_locale_fille) do
          create :structure_locale, structure_referente: structure_administrative
        end
        let!(:admin_fille) { create :compte_admin, structure: structure_locale_fille }
        let(:compte_existant) { create :compte_conseiller, structure: structure_locale_fille }
        let!(:campagne) { create :campagne, compte: compte_existant }

        before { get :edit, params: { id: compte_existant.id } }

        it "le champ structure est visible mais non éditable et préserve la structure" do
          expect(response.body).to include('id="compte_structure_input"')
          expect(response.body).to include('disabled="disabled"')
          expect(response.body).to include(structure_locale_fille.nom)
        end
      end

      context "lors de l'édition d'un compte appartenant à la structure administrative" do
        let(:compte_existant) { create :compte_conseiller, structure: structure_administrative }

        before { get :edit, params: { id: compte_existant.id } }

        it "le champ structure est visible mais non éditable" do
          expect(response.body).to include('id="compte_structure_input"')
          expect(response.body).to include(structure_administrative.nom)
          expect(response.body).to include('disabled="disabled"')
        end
      end
    end
  end
end
