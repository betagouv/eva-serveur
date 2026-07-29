require 'rails_helper'

describe EvaluationEva do
  it { is_expected.to belong_to(:responsable_suivi).optional }
  it { is_expected.to have_one :donnee_sociodemographique }

  describe 'scopes' do
    describe '.sans_mise_en_action' do
      let!(:evaluation_avec_mise_en_action) { create :evaluation, :eva, :avec_mise_en_action }
      let!(:evaluation_sans_mise_en_action) { create :evaluation, :eva }

      it 'retourne les évaluations sans mise en action' do
        expect(described_class.sans_mise_en_action).to eq [ evaluation_sans_mise_en_action ]
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
end
