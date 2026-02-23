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
    context "quand l'étape est 'usage' et la session ne contient pas les params d'inscription" do
      before do
        structure = build(:structure_locale, siret: compte.siret_pro_connect, idcc: [ "3" ])
        allow(RechercheStructureParSiret).to receive(:new).and_return(
          instance_double(RechercheStructureParSiret, call: structure)
        )
      end

      it "redirige vers l'étape parametrage" do
        get :show, params: { etape: "usage" }

        expect(response).to redirect_to(inscription_structure_path(etape: "parametrage"))
      end
    end

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

        patch :update, params: {
          structure: structure_params.merge(type_structure: "entreprise"),
          commit: "creer"
        }

        expect(AffiliationOpcoService).to have_received(:new)
        expect(service_double).to have_received(:affilie_opcos)
      end

      context "quand l'utilisateur sélectionne un OPCO" do
        let!(:opco1) { create(:opco, nom: "OPCO 1") }

        it "associe l'OPCO sélectionné après l'affiliation automatique" do
          patch :update, params: {
            structure: structure_params.merge(type_structure: "entreprise", opco_id: opco1.id),
            commit: "creer"
          }

          structure_creée.reload
          expect(structure_creée.opco).to eq(opco1)
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

      context "quand le type_structure n'est pas entreprise" do
        it "redirige vers l'étape usage et enregistre les params en session" do
          patch :update, params: {
            structure_locale: structure_params.merge(opco_id: opco.id),
            commit: "Confirmer la création"
          }

          expect(response).to redirect_to(inscription_structure_path(etape: "usage"))
          expect(session[:structure_params_inscription]).to include(
            "nom" => "Ma Structure",
            "type_structure" => "mission_locale"
          )
          expect(session[:structure_params_inscription]["opco_id"]).to eq(opco.id.to_s)
        end
      end
    end

    context "quand l'action est 'creer_avec_usage'" do
      let(:params_inscription) do
        { "nom" => "Ma Structure", "type_structure" => "mission_locale", "opco_id" => opco.id.to_s }
      end
      let(:structure_creée) do
        build(:structure_locale, siret: compte.siret_pro_connect, idcc: [ "3" ])
      end

      before do
        allow(FabriqueStructure).to receive(:cree_depuis_siret) do |siret, attrs|
          structure_creée.assign_attributes(attrs) if attrs.present?
          structure_creée.idcc = [ "3" ] unless structure_creée.idcc.present?
          structure_creée.save!
          structure_creée.reload
          structure_creée
        end
      end

      context "sans session (params d'inscription manquants)" do
        it "redirige vers l'étape parametrage" do
          patch :update, params: {
            structure_locale: { usage: AvecUsage::USAGE_BENEFICIAIRES },
            commit: "creer_avec_usage"
          }

          expect(response).to redirect_to(inscription_structure_path(etape: "parametrage"))
        end
      end

      context "avec usage Eva: bénéficiaires" do
        before { session[:structure_params_inscription] = params_inscription }

        it "crée la structure avec l'usage bénéficiaires et ne crée pas de campagnes" do
          campagne_createur = instance_double(CampagneCreateur, cree_campagne_opco!: true)
          allow(CampagneCreateur).to receive(:new).and_return(campagne_createur)

          patch :update, params: {
            structure_locale: params_inscription.merge(usage: AvecUsage::USAGE_BENEFICIAIRES),
            commit: "creer_avec_usage"
          }

          structure_creée.reload
          expect(structure_creée.usage).to eq(AvecUsage::USAGE_BENEFICIAIRES)
          expect(CampagneCreateur).not_to have_received(:new)
        end
      end

      context "avec usage Eva: entreprises" do
        before { session[:structure_params_inscription] = params_inscription }

        it "crée la structure avec l'usage entreprises et déclenche la création de campagnes" do
          campagne_createur = instance_double(CampagneCreateur, cree_campagne_opco!: true)
          allow(CampagneCreateur).to receive(:new).and_return(campagne_createur)

          patch :update, params: {
            structure_locale: params_inscription.merge(usage: AvecUsage::USAGE_ENTREPRISES),
            commit: "creer_avec_usage"
          }

          structure_creée.reload
          expect(structure_creée.usage).to eq(AvecUsage::USAGE_ENTREPRISES)
          expect(CampagneCreateur).to have_received(:new).with(structure_creée, compte)
          expect(campagne_createur).to have_received(:cree_campagne_opco!)
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
