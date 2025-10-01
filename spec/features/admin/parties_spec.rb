require 'rails_helper'

describe 'Admin - Parties', type: :feature do
  before { se_connecter_comme_superadmin }

  let!(:situation) { create :situation }
  let!(:autre_situation) { create :situation_inventaire }

  describe 'index' do
    let(:beneficiaire1) { create :beneficiaire, nom: 'beneficiaire 1' }
    let(:beneficiaire2) { create :beneficiaire, nom: 'beneficiaire 2' }
    let(:beneficiaire3) { create :beneficiaire, nom: 'beneficiaire inventaire' }
    let(:evaluation1) { create :evaluation, beneficiaire: beneficiaire1 }
    let(:evaluation2) { create :evaluation, beneficiaire: beneficiaire2 }
    let(:evaluation3) { create :evaluation, beneficiaire: beneficiaire3 }
    let!(:partie1) { create :partie, situation: situation, evaluation: evaluation1 }
    let!(:partie2) { create :partie, situation: situation, evaluation: evaluation2 }
    let!(:partie_inventaire) do
      create :partie,
             situation: autre_situation,
             evaluation: evaluation3
    end

    before { visit admin_situation_parties_path(situation) }

    it do
      expect(page).to have_content('beneficiaire 1 - ')
      expect(page).not_to have_content('beneficiaire inventaire - ')
    end
  end
end
