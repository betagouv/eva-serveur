require 'rails_helper'

RSpec.describe LieurEvaluations, type: :model do
  describe '#call' do
    let!(:beneficiaire_ancien) { create(:beneficiaire, created_at: 3.years.ago) }
    let!(:beneficiaire_recent) { create(:beneficiaire, created_at: 1.year.ago) }

    let!(:evaluation_1) { create(:evaluation, beneficiaire: beneficiaire_recent) }
    let!(:evaluation_2) { create(:evaluation, beneficiaire: beneficiaire_ancien) }
    let!(:evaluation_3) { create(:evaluation, beneficiaire: beneficiaire_recent) }

    let(:evaluations) { Evaluation.all }


    it 'associe toutes les évaluations au bénéficiaire le plus ancien' do
      described_class.new(evaluations).call

      expect(evaluation_1.reload.beneficiaire).to eq(beneficiaire_ancien)
      expect(evaluation_2.reload.beneficiaire).to eq(beneficiaire_ancien)
      expect(evaluation_3.reload.beneficiaire).to eq(beneficiaire_ancien)
    end
  end
end
