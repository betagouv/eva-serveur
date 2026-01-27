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
      context "avec une structure temporaire (non persistée)" do
        before do
          # Mock RechercheStructureParSiret pour retourner une structure non persistée
          structure = build(:structure_locale, siret: compte.siret_pro_connect, idcc: [ "3" ])
          allow(RechercheStructureParSiret).to receive(:new).and_return(
            instance_double(RechercheStructureParSiret, call: structure)
          )
        end

        it "prépare la structure et appelle le service d'affiliation OPCO (même non persistée)" do
          service_double = instance_double(AffiliationOpcoService)
          allow(AffiliationOpcoService).to receive(:new).and_return(service_double)
          allow(service_double).to receive(:affilie_opcos)

          get :show

          expect(AffiliationOpcoService).to have_received(:new)
          expect(service_double).to have_received(:affilie_opcos)
          expect(response).to have_http_status(:success)
        end
      end

      context "avec une structure existante (persistée)" do
        let!(:structure_existante) {
 create(:structure_locale, siret: compte.siret_pro_connect, idcc: [ "3" ]) }

        before do
          # Mock RechercheStructureParSiret pour retourner une structure persistée
          allow(RechercheStructureParSiret).to receive(:new).and_return(
            instance_double(RechercheStructureParSiret, call: structure_existante)
          )
        end

        it "prépare la structure et appelle le service d'affiliation OPCO" do
          service_double = instance_double(AffiliationOpcoService)
          allow(AffiliationOpcoService).to receive(:new).and_return(service_double)
          allow(service_double).to receive(:affilie_opcos)

          get :show

          expect(AffiliationOpcoService).to have_received(:new).with(structure_existante)
          expect(service_double).to have_received(:affilie_opcos)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "quand la structure est déjà préparée" do
      let!(:structure) {
 create(:structure_locale, :avec_admin, siret: "13002526500013", idcc: [ "3" ]) }
      let(:compte_avec_structure) {
        create(:compte_pro_connect, etape_inscription: "assignation_structure",
        siret_pro_connect: "13002526500013", structure: structure) }

      before do
        sign_in compte_avec_structure
        # Empêcher RechercheStructureParSiret d'être appelé
        allow(RechercheStructureParSiret).to receive(:new).and_return(
          instance_double(RechercheStructureParSiret, call: nil)
        )
      end

      it "appelle le service d'affiliation OPCO car la structure est persistée" do
        service_double = instance_double(AffiliationOpcoService)
        allow(AffiliationOpcoService).to receive(:new).and_return(service_double)
        allow(service_double).to receive(:affilie_opcos)

        get :show

        expect(AffiliationOpcoService).to have_received(:new).with(structure)
        expect(service_double).to have_received(:affilie_opcos)
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
          if structure_creée.is_a?(StructureLocale)
            structure_creée.affecte_usage_entreprise_si_necessaire
          end
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

      context "quand l'utilisateur sélectionne un OPCO" do
        let!(:opco1) { create(:opco, nom: "OPCO 1") }

        it "associe l'OPCO sélectionné après l'affiliation automatique" do
          patch :update, params: {
            structure: structure_params.merge(opco_id: opco1.id),
            commit: "creer"
          }

          structure_creée.reload
          expect(structure_creée.opcos).to contain_exactly(opco1)
        end
      end

      context "quand le type_structure est entreprise" do
        let(:structure_params_entreprise) do
          structure_params.merge(type_structure: "entreprise")
        end

        it "affecte l'usage 'Eva: entreprises' à la structure" do
          patch :update, params: { structure: structure_params_entreprise, commit: "creer" }

          structure_creée.reload
          expect(structure_creée.type_structure).to eq("entreprise")
          expect(structure_creée.usage).to eq("Eva: entreprises")
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
