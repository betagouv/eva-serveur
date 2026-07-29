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
  end
end
