require 'rails_helper'

describe EvaluationEva do
  it { is_expected.to belong_to(:responsable_suivi).optional }
  it { is_expected.to have_one :donnee_sociodemographique }

  describe 'scopes' do
    describe '.mise_en_action_a_renseigner' do
      let!(:evaluation_avec_mise_en_action) { create :evaluation, :eva, :avec_mise_en_action }
      let!(:evaluation_sans_mise_en_action) { create :evaluation, :eva }
      let!(:evaluation_je_ne_sais_pas) do
        create :evaluation, :eva, :avec_mise_en_action, effectuee: nil
      end

      it 'retourne les évaluations sans mise en action ou avec une réponse « je ne sais pas »' do
        expect(described_class.mise_en_action_a_renseigner)
          .to contain_exactly(evaluation_sans_mise_en_action, evaluation_je_ne_sais_pas)
      end
    end

    describe '.competences_de_base_completes' do
      let!(:evaluation_complete) { create :evaluation, :eva, completude: 'complete' }
      let!(:evaluation_incomplete) { create :evaluation, :eva, completude: 'incomplete' }
      let!(:evaluation_transversales_incompletes) do
        create :evaluation, :eva, completude: 'competences_transversales_incompletes'
      end

      it do
        expect(described_class.competences_de_base_completes).to contain_exactly(
          evaluation_transversales_incompletes,
          evaluation_complete
        )
      end
    end

    describe ".diagnostic" do
      let!(:evaluation_diagnostic) { create(:evaluation, :eva, :diagnostic) }
      let!(:evaluation_positionnement) { create(:evaluation, :eva, :positionnement) }
      let!(:evaluation_evapro) { create(:evaluation, :eva, :avec_parcours_evapro) }

      it "retourne uniquement les évaluations du programme diagnostic (hors Eva Pro)" do
        resultats = described_class.diagnostic

        expect(resultats).to include(evaluation_diagnostic)
        expect(resultats).not_to include(evaluation_positionnement)
        expect(resultats).not_to include(evaluation_evapro)
      end
    end

    describe ".positionnement" do
      let!(:evaluation_diagnostic) { create(:evaluation, :eva, :diagnostic) }
      let!(:evaluation_positionnement) { create(:evaluation, :eva, :positionnement) }
      let!(:evaluation_evapro) { create(:evaluation, :eva, :avec_parcours_evapro) }

      it "retourne uniquement les évaluations du programme positionnement" do
        resultats = described_class.positionnement

        expect(resultats).to include(evaluation_positionnement)
        expect(resultats).not_to include(evaluation_diagnostic)
        expect(resultats).not_to include(evaluation_evapro)
      end
    end
  end

  describe '#responsables_suivi' do
    let!(:structure) { create :structure }
    let!(:structure2) { create :structure }
    let!(:compte1) { create :compte, structure: structure }
    let!(:compte2) { create :compte, structure: structure }
    let!(:compte_en_attente) { create :compte_conseiller, :en_attente, structure: structure }
    let!(:compte_refusee) { create :compte_conseiller, :refusee, structure: structure }
    let!(:compte_autre_structure) { create :compte, structure: structure2 }
    let!(:campagne) { create :campagne, compte: compte1 }
    let(:evaluation) { build :evaluation, :eva, campagne: campagne }

    it "retourne les responsables de suivi possible pour l'évaluation" do
      expect(evaluation.responsables_suivi).to contain_exactly(compte1, compte2)
    end
  end

  describe "#enregistre_mise_en_action" do
    let(:date_du_jour) { Time.zone.local(2023, 1, 1, 12, 0, 0) }

    context "quand il y a une mise en action associée" do
      let!(:evaluation) { create :evaluation, :eva, :avec_mise_en_action, effectuee: true }

      it "enregistre la réponse sur la mise en action existante, sans en créer une autre" do
        expect { evaluation.enregistre_mise_en_action(false) }
          .not_to change(MiseEnAction, :count)

        expect(evaluation.mise_en_action.reload.effectuee).to be(false)
      end
    end

    context "quand il n'y a pas de mise en action associée" do
      let!(:evaluation) { create :evaluation, :eva }

      it "crée et enregistre une réponse true" do
        Timecop.freeze(date_du_jour) do
          evaluation.enregistre_mise_en_action(true)
        end

        expect(evaluation.mise_en_action.effectuee).to be(true)
        expect(evaluation.mise_en_action.repondue_le).to eq(date_du_jour)
      end

      it "crée et enregistre une réponse false" do
        Timecop.freeze(date_du_jour) do
          evaluation.enregistre_mise_en_action(false)
        end

        expect(evaluation.mise_en_action.effectuee).to be(false)
        expect(evaluation.mise_en_action.repondue_le).to eq(date_du_jour)
      end
    end
  end
end
