require 'rails_helper'

describe 'Admin Beneficiaires actions groupées', type: :request do
  let!(:mon_compte) { create :compte_superadmin }
  let(:parcours_type) { create :parcours_type, :competences_de_base }
  let(:campagne) do
    create :campagne, compte: mon_compte, libelle: 'Paris 2019', code: 'PARIS2019',
                      parcours_type: parcours_type
  end
  let!(:beneficiaire1) { create :beneficiaire }
  let!(:evaluation1) { create :evaluation, campagne: campagne, beneficiaire: beneficiaire1 }

  before do
    sign_in mon_compte
  end

  describe "GET index" do
    it "affiche la liste dans le cadre de l'administration, avec ses filtres" do
      get admin_beneficiaires_path

      expect(response.body).to include("<title>Bénéficiaires | eva</title>")
      expect(response.body).to include("fr-header")
      expect(response.body).to include("id=\"filters_sidebar_section\"")
      expect(response.body).to include("id=\"beneficiaires-selection\"")
    end

    it "pagine la liste avec la pagination DSFR" do
      create :evaluation, campagne: campagne, beneficiaire: create(:beneficiaire)

      get admin_beneficiaires_path(per_page: 1)

      expect(response.body).to include("fr-pagination__list")
    end

    it "sert toujours la recherche JSON utilisée par les autres filtres" do
      get admin_beneficiaires_path(format: :json)

      expect(response.parsed_body.pluck("id")).to include(beneficiaire1.id)
    end
  end

  describe "POST renseigner_suivi_groupe" do
    let!(:beneficiaire2) { create :beneficiaire }

    it "renvoie sur la liste complète avec les bénéficiaires sélectionnés" do
      post renseigner_suivi_groupe_admin_beneficiaires_path, params: {
        beneficiaire_ids: [ beneficiaire1.id, beneficiaire2.id ],
        effectuee: "true"
      }

      expect(response).to redirect_to(
        admin_beneficiaires_path(selection: [ beneficiaire1.id, beneficiaire2.id ])
      )
    end

    it "revient sur la liste quand la réponse est invalide" do
      post renseigner_suivi_groupe_admin_beneficiaires_path, params: {
        beneficiaire_ids: [ beneficiaire1.id ], effectuee: "peut-etre"
      }

      expect(response).to redirect_to(admin_beneficiaires_path)
    end

    context "quand le compte n'a pas le droit de renseigner le suivi" do
      let!(:mon_compte) { create :compte_charge_mission_regionale, :structure_avec_admin }

      it "refuse l'action" do
        post renseigner_suivi_groupe_admin_beneficiaires_path, params: {
          beneficiaire_ids: [ beneficiaire1.id ], effectuee: "true"
        }

        expect(response).to redirect_to(admin_root_path)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "POST fusionner" do
    let!(:beneficiaire2) { create :beneficiaire }
    let!(:evaluation2) { create :evaluation, campagne: campagne, beneficiaire: beneficiaire2 }

    it "lie les bénéficiaires sélectionnés" do
      post fusionner_admin_beneficiaires_path, params: {
        beneficiaire_ids: [ beneficiaire1.id, beneficiaire2.id ]
      }

      expect(beneficiaire1.reload.evaluations).to contain_exactly(evaluation1, evaluation2)
      expect(beneficiaire2.reload.deleted_at).not_to be_nil
      expect(response).to redirect_to("/admin/beneficiaires/#{beneficiaire1.id}")
    end

    context "quand le compte n'a pas le droit de fusionner" do
      let!(:mon_compte) { create :compte_charge_mission_regionale, :structure_avec_admin }

      it "refuse l'action" do
        post fusionner_admin_beneficiaires_path, params: {
          beneficiaire_ids: [ beneficiaire1.id, beneficiaire2.id ]
        }

        expect(response).to redirect_to(admin_root_path)
        expect(beneficiaire2.reload.deleted_at).to be_nil
      end
    end

    it "refuse de fusionner un seul bénéficiaire" do
      post fusionner_admin_beneficiaires_path, params: { beneficiaire_ids: [ beneficiaire1.id ] }

      expect(response).to redirect_to(admin_beneficiaires_path)
      expect(flash[:alert]).to eq I18n.t("admin.beneficiaires.fusion.errors.alert")
    end
  end
end
