require 'rails_helper'

describe 'Admin - Comparaison', type: :feature do
  let(:compte) { create :compte }
  let(:beneficiaire) { create :beneficiaire }
  let(:evaluations) do
    [
      create(:evaluation, beneficiaire: beneficiaire),
      create(:evaluation, beneficiaire: beneficiaire)
    ]
  end

  before { connecte(compte) }

  describe 'index' do
    before do
      visit(admin_beneficiaire_comparaison_path(
        beneficiaire, evaluation_ids: evaluations.map(&:id)
      ))
    end

    it do
      expect(page).to have_http_status(200)
      expect(page).to have_content 'Comparer les évaluations'
    end
  end
end
