# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Parties', type: :feature do
  before { se_connecter_comme_superadmin }

  let!(:situation) { create :situation }
  let!(:autre_situation) { create :situation_inventaire }

  describe 'index' do
    let(:evaluation1) { create :evaluation, nom: 'evaluation 1' }
    let(:evaluation2) { create :evaluation, nom: 'evaluation 2' }
    let(:evaluation3) { create :evaluation, nom: 'evaluation inventaire' }
    let!(:partie1) { create :partie, situation: situation, evaluation: evaluation1 }
    let!(:partie2) { create :partie, situation: situation, evaluation: evaluation2 }
    let!(:partie_inventaire) do
      create :partie,
             situation: autre_situation,
             evaluation: evaluation3
    end

    before { visit admin_situation_parties_path(situation) }

    it do
      expect(page).to have_content('Roger')
      expect(page).not_to have_content('evaluation inventaire')
    end
  end
end
