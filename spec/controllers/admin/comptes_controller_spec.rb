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

  describe "suppression" do
    let(:structure) { create :structure_locale }
    let!(:compte_connecte) { create :compte_admin, structure: structure }
    let!(:compte_a_supprimer) { create :compte_conseiller, structure: structure }

    before { sign_in compte_connecte }

    it "redirige vers la liste avec les filtres préservés" do
      referer = admin_comptes_path(q: { email_contains: "test" })
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: compte_a_supprimer.id }

      expect(response).to redirect_to(referer)
    end

    it "redirige vers la liste depuis la page show" do
      referer = admin_compte_path(compte_a_supprimer)
      request.headers["HTTP_REFERER"] = referer
      delete :destroy, params: { id: compte_a_supprimer.id }

      expect(response).to redirect_to(admin_comptes_path)
    end
  end

  describe "Changement de structure par un superadmin" do
    let(:structure_superadmin) { create :structure_locale }
    let(:structure_origine) { create :structure_locale }
    let(:structure_destination) { create :structure_locale }
    let!(:superadmin) { create :compte_superadmin, structure: structure_superadmin }

    before { sign_in superadmin }

    it "peut déplacer le dernier admin d'une structure" do
      dernier_admin = create :compte_admin, structure: structure_origine

      put :update, params: {
        id: dernier_admin.id,
        compte: { structure_id: structure_destination.id }
      }

      expect(dernier_admin.reload.structure).to eq(structure_destination)
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

  describe "liste comptes OPCO" do
    let(:opco) { create(:opco) }
    let(:structure_opco) do
      create(:structure_administrative, :avec_admin, usage: AvecUsage::USAGE_EVAPRO, opco: opco)
    end
    let(:structure_fille_opco) do
      create(
        :structure_locale,
        :avec_admin,
        usage: AvecUsage::USAGE_EVAPRO,
        opco: opco,
        structure_referente: structure_opco
      )
    end
    let(:autre_structure_meme_opco) do
      create(:structure_locale, :avec_admin, usage: AvecUsage::USAGE_EVAPRO, opco: opco)
    end
    let!(:compte_opco) do
      create(:compte_conseiller, structure: structure_opco, prenom: "Visible")
    end
    let!(:compte_structure_fille) do
      create(:compte_conseiller, structure: structure_fille_opco, prenom: "VisibleFille")
    end
    let!(:compte_hors_opco) do
      create(:compte_conseiller, structure: autre_structure_meme_opco, prenom: "Invisible")
    end
    let!(:compte_connecte) { create(:compte_admin, :acceptee, structure: structure_opco) }

    before { sign_in compte_connecte }

    it "affiche les comptes de sa structure et de ses structures filles" do
      get :index

      expect(response).to be_successful
      expect(response.body).to include("Visible")
      expect(response.body).to include("VisibleFille")
      expect(response.body).not_to include("Invisible")
    end
  end

  describe "liste comptes OPCO conseiller" do
    let(:opco) { create(:opco) }
    let(:structure_opco) do
      create(:structure_administrative, :avec_admin, usage: AvecUsage::USAGE_EVAPRO, opco: opco)
    end
    let(:autre_structure_meme_opco) do
      create(:structure_locale, :avec_admin, usage: AvecUsage::USAGE_EVAPRO, opco: opco)
    end
    let!(:compte_meme_structure) do
      create(:compte_conseiller, structure: structure_opco, prenom: "VisibleConseiller")
    end
    let!(:compte_meme_opco_autre_structure) do
      create(:compte_conseiller, structure: autre_structure_meme_opco,
prenom: "InvisibleConseiller")
    end
    let!(:compte_connecte) { create(:compte_conseiller, :acceptee, structure: structure_opco) }

    before { sign_in compte_connecte }

    it "n'affiche que les comptes de sa structure" do
      get :index

      expect(response).to be_successful
      expect(response.body).to include("VisibleConseiller")
      expect(response.body).not_to include("InvisibleConseiller")
    end
  end

  describe "liste comptes superadmin" do
    let(:structure_superadmin) { create(:structure_locale) }
    let!(:superadmin) { create(:compte_superadmin, structure: structure_superadmin) }
    let(:structure_cible) { create(:structure_locale, :avec_admin) }
    let!(:compte_structure_cible) do
      create(:compte_conseiller, structure: structure_cible, prenom: "VisibleSuperadmin")
    end
    let(:structure_hors_cible) { create(:structure_locale, :avec_admin) }
    let!(:compte_hors_cible) do
      create(:compte_conseiller, structure: structure_hors_cible, prenom: "InvisibleSuperadmin")
    end

    before { sign_in superadmin }

    it "affiche les comptes de la structure filtrée même hors parenté" do
      get :index, params: { q: { structure_id_eq: structure_cible.id } }

      expect(response).to be_successful
      expect(response.body).to include("VisibleSuperadmin")
      expect(response.body).not_to include("InvisibleSuperadmin")
    end

    it "n'affiche que les comptes en attente de la structure filtrée" do
      compte_en_attente_cible = create(
        :compte_conseiller,
        :en_attente,
        structure: structure_cible,
        email: "attente.cible@example.org"
      )
      create(
        :compte_conseiller,
        :en_attente,
        structure: structure_hors_cible,
        email: "attente.hors-cible@example.org"
      )

      get :index, params: { q: { structure_id_eq: structure_cible.id } }

      expect(response).to be_successful
      expect(response.body).to include(compte_en_attente_cible.email)
      expect(response.body).not_to include("attente.hors-cible@example.org")
    end
  end

  describe "liste comptes CMR" do
    let(:structure_cmr) { create(:structure_locale, :avec_admin) }
    let(:autre_structure) { create(:structure_locale, :avec_admin) }
    let!(:compte_cmr) do
      create(:compte_charge_mission_regionale, :acceptee, structure: structure_cmr)
    end
    let!(:compte_structure_cmr) do
      create(:compte_conseiller, :acceptee, structure: structure_cmr, prenom: "VisibleCMR")
    end
    let!(:compte_autre_structure) do
      create(:compte_conseiller, :acceptee, structure: autre_structure, prenom: "VisibleAutre")
    end

    before { sign_in compte_cmr }

    it "affiche les comptes de toutes les structures en lecture" do
      get :index

      expect(response).to be_successful
      expect(response.body).to include("VisibleCMR")
      expect(response.body).to include("VisibleAutre")
    end
  end
end
