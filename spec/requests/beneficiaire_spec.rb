require 'rails_helper'

describe 'Admin Beneficiaires Batch Action', type: :request do
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

  describe "POST batch_action renseigner_suivi_groupe" do
    let(:attributs_concernee) do
      { synthese_competences_de_base: :illettrisme_potentiel, completude: "complete" }
    end
    let!(:evaluation_eva_concernee) do
      create :evaluation, :eva, campagne: campagne, beneficiaire: beneficiaire1,
             **attributs_concernee, debutee_le: "2021-01-01"
    end

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DATE_STATUT_SUIVI").and_return("2020-01-01")
    end

    it "redirige vers la liste des bénéficiaires" do
      post '/admin/beneficiaires/batch_action', params: {
        batch_action: 'renseigner_suivi_groupe',
        collection_selection: [ beneficiaire1.id ],
        effectuee: "true"
      }
      expect(response).to redirect_to("/admin/beneficiaires")
    end

    it "crée une MiseEnAction avec effectuee=true pour l'évaluation concernée" do
      post '/admin/beneficiaires/batch_action', params: {
        batch_action: 'renseigner_suivi_groupe',
        collection_selection: [ beneficiaire1.id ],
        effectuee: "true"
      }
      expect(evaluation_eva_concernee.reload.mise_en_action.effectuee).to be(true)
    end

    it "renseigne la remédiation quand effectuee=true avec une qualification" do
      post '/admin/beneficiaires/batch_action', params: {
        batch_action: 'renseigner_suivi_groupe',
        collection_selection: [ beneficiaire1.id ],
        effectuee: "true",
        qualification: "formation_metier"
      }
      expect(evaluation_eva_concernee.reload.mise_en_action.remediation).to eq("formation_metier")
    end

    it "renseigne la difficulté quand effectuee=false avec une qualification" do
      post '/admin/beneficiaires/batch_action', params: {
        batch_action: 'renseigner_suivi_groupe',
        collection_selection: [ beneficiaire1.id ],
        effectuee: "false",
        qualification: "freins_peripheriques"
      }
      mise_en_action = evaluation_eva_concernee.reload.mise_en_action
      expect(mise_en_action.difficulte).to eq("freins_peripheriques")
    end

    it "renseigne le motif action_prevue quand effectuee=je_ne_sais_pas" do
      post '/admin/beneficiaires/batch_action', params: {
        batch_action: 'renseigner_suivi_groupe',
        collection_selection: [ beneficiaire1.id ],
        effectuee: MiseEnAction::REPONSE_JE_NE_SAIS_PAS
      }
      mise_en_action = evaluation_eva_concernee.reload.mise_en_action
      expect(mise_en_action.motif).to eq("action_prevue")
      expect(mise_en_action.date_revue).to eq(Date.current + 7)
    end

    context "avec plusieurs évaluations pour un même bénéficiaire" do
      let!(:evaluation_eva_ancienne) do
        create :evaluation, :eva, campagne: campagne, beneficiaire: beneficiaire1,
               **attributs_concernee, debutee_le: "2020-06-01"
      end

      it "enregistre la mise en action sur l'évaluation la plus récente uniquement" do
        post '/admin/beneficiaires/batch_action', params: {
          batch_action: 'renseigner_suivi_groupe',
          collection_selection: [ beneficiaire1.id ],
          effectuee: "true"
        }
        expect(evaluation_eva_concernee.reload.mise_en_action).to be_present
        expect(evaluation_eva_ancienne.reload.mise_en_action).to be_nil
      end
    end
  end

  describe "POST batch_action fusionner" do
    let!(:beneficiaire2) { create :beneficiaire }
    let!(:evaluation2) { create :evaluation, campagne: campagne, beneficiaire: beneficiaire2 }

    it "lie les bénéficiaires sélectionnés" do
      post '/admin/beneficiaires/batch_action', params: {
        batch_action: 'fusionner',
        collection_selection: [ beneficiaire1.id, beneficiaire2.id ]
      }

      expect(beneficiaire1.reload.evaluations).to contain_exactly(evaluation1, evaluation2)
      expect(beneficiaire2.reload.deleted_at).not_to be_nil
      expect(response).to redirect_to("/admin/beneficiaires/#{beneficiaire1.id}")
    end
  end
end
