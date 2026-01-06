require "rails_helper"

describe Inscription::StructuresController, type: :controller do
  let(:compte) {
 create(:compte_pro_connect, etape_inscription: "assignation_structure", structure: nil,
siret_pro_connect: "13002526500013") }
  let(:opco) { create(:opco, nom: "OPCO Test", idcc: [ "3" ]) }

  before do
    sign_in compte
  end

  describe "GET show" do
    context "quand la structure n'est pas encore préparée" do
      before do
        # Mock RechercheStructureParSiret
        structure = build(:structure_locale, siret: compte.siret_pro_connect, idcc: [ "3" ])
        allow(RechercheStructureParSiret).to receive(:new).and_return(
          instance_double(RechercheStructureParSiret, call: structure)
        )
      end

      it "prépare la structure et appelle le service d'affiliation OPCO" do
        service_double = instance_double(AffiliationOpcoService)
        allow(AffiliationOpcoService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:affilie_opcos)

        get :show

        expect(AffiliationOpcoService).to have_received(:new)
        expect(service_double).to have_received(:affilie_opcos)
        expect(response).to have_http_status(:success)
      end
    end

    context "quand la structure est déjà préparée" do
      let!(:structure) { create(:structure_locale, siret: compte.siret_pro_connect) }

      before do
        compte.update(structure: structure)
        compte.reload
        # S'assurer que current_compte retourne le compte avec la structure chargée
        compte.structure # Force le chargement de la structure
        allow(controller).to receive(:current_compte).and_return(compte)
        # Empêcher RechercheStructureParSiret d'être appelé
        allow(RechercheStructureParSiret).to receive(:new).and_return(
          instance_double(RechercheStructureParSiret, call: nil)
        )
      end

      it "n'appelle pas le service d'affiliation OPCO" do
        expect(AffiliationOpcoService).not_to receive(:new)

        get :show

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH update" do
    let(:structure_params) do
      {
        nom: "Ma Structure",
        type_structure: "mission_locale"
      }
    end

    context "quand l'action est 'creer'" do
      let(:structure_creée) {
        build(:structure_locale, siret: compte.siret_pro_connect, idcc: [ "3" ]) }

      before do
        # Mock FabriqueStructure pour retourner une structure avec IDCC
        allow(FabriqueStructure).to receive(:cree_depuis_siret) do |siret, params|
          structure_creée.assign_attributes(params) if params.present?
          # S'assurer que l'IDCC est bien défini avant la sauvegarde
          structure_creée.idcc = [ "3" ] unless structure_creée.idcc.present?
          structure_creée.save!
          structure_creée.reload
          structure_creée
        end
      end

      it "appelle le service d'affiliation OPCO automatique" do
        service_double = instance_double(AffiliationOpcoService)
        allow(AffiliationOpcoService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:affilie_opcos)

        patch :update, params: { structure: structure_params, commit: "creer" }

        expect(AffiliationOpcoService).to have_received(:new)
        expect(service_double).to have_received(:affilie_opcos)
      end

      context "quand l'utilisateur sélectionne des OPCOs" do
        let!(:opco1) { create(:opco, nom: "OPCO 1") }
        let!(:opco2) { create(:opco, nom: "OPCO 2") }

        it "associe les OPCOs sélectionnés après l'affiliation automatique" do
          patch :update, params: {
            structure: structure_params.merge(opco_ids: [ opco1.id, opco2.id ]),
            commit: "creer"
          }

          structure_creée.reload
          expect(structure_creée.opcos).to contain_exactly(opco1, opco2)
        end
      end
    end

    context "quand l'action est 'rejoindre'" do
      let!(:structure) { create(:structure_locale, siret: compte.siret_pro_connect, idcc: [ "3" ]) }

      before do
        compte.update(structure: structure)
      end

      it "appelle le service d'affiliation OPCO lors de la préparation" do
        service_double = instance_double(AffiliationOpcoService)
        allow(AffiliationOpcoService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:affilie_opcos)

        patch :update, params: { commit: "rejoindre" }

        expect(AffiliationOpcoService).to have_received(:new)
        expect(service_double).to have_received(:affilie_opcos)
      end
    end
  end
end
