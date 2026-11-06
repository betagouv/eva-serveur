require 'rails_helper'

describe Beneficiaires::EnregistreSuiviGroupe do
  let(:parcours_type) { create :parcours_type, :competences_de_base }
  let(:campagne) { create :campagne, parcours_type: parcours_type }
  let(:beneficiaire) { create :beneficiaire }
  let(:attributs_concernee) do
    { synthese_competences_de_base: :illettrisme_potentiel, completude: "complete" }
  end
  let!(:evaluation_concernee) do
    create :evaluation, :eva, campagne: campagne, beneficiaire: beneficiaire,
           **attributs_concernee, debutee_le: "2021-01-01"
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("DATE_STATUT_SUIVI").and_return("2020-01-01")
  end

  def service(effectuee:, qualification: nil, precision_autre: nil)
    described_class.new([ beneficiaire.id ], effectuee, qualification, precision_autre)
  end

  describe "#call" do
    it "retourne :effectuee_invalide si le paramètre effectuee est absent" do
      expect(described_class.new([], nil, nil, nil).call).to eq(:effectuee_invalide)
    end

    it "crée une MiseEnAction avec effectuee=true" do
      service(effectuee: "true").call
      expect(evaluation_concernee.reload.mise_en_action.effectuee).to be(true)
    end

    it "crée une MiseEnAction avec effectuee=false" do
      service(effectuee: "false").call
      expect(evaluation_concernee.reload.mise_en_action.effectuee).to be(false)
    end

    it "crée une MiseEnAction avec effectuee=nil quand effectuee=pas_encore" do
      service(effectuee: MiseEnAction::REPONSE_PAS_ENCORE).call
      expect(evaluation_concernee.reload.mise_en_action.effectuee).to be_nil
    end

    it "renseigne la remédiation quand effectuee=true avec une qualification" do
      service(effectuee: "true", qualification: "formation_metier").call
      expect(evaluation_concernee.reload.mise_en_action.remediation).to eq("formation_metier")
    end

    it "renseigne la difficulté quand effectuee=false avec une qualification" do
      service(effectuee: "false", qualification: "freins_peripheriques").call
      expect(evaluation_concernee.reload.mise_en_action.difficulte).to eq("freins_peripheriques")
    end

    context "avec plusieurs évaluations pour un même bénéficiaire" do
      let!(:evaluation_ancienne) do
        create :evaluation, :eva, campagne: campagne, beneficiaire: beneficiaire,
               **attributs_concernee, debutee_le: "2020-06-01"
      end

      it "enregistre la mise en action sur l'évaluation la plus récente uniquement" do
        service(effectuee: "true").call
        expect(evaluation_concernee.reload.mise_en_action).to be_present
        expect(evaluation_ancienne.reload.mise_en_action).to be_nil
      end
    end

    it "retourne le nombre de bénéficiaires traités" do
      expect(service(effectuee: "true").call).to eq({ succes: 1 })
    end
  end
end
