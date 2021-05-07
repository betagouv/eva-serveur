# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Parties', type: :feature do
  before { se_connecter_comme_superadmin }
  let!(:situation) { create :situation }

  describe 'index' do
    let(:evaluation1) { create :evaluation, nom: 'evaluation 1' }
    let(:evaluation2) { create :evaluation, nom: 'evaluation 2' }
    let!(:partie1) { create :partie, situation: situation, evaluation: evaluation1 }
    let!(:partie2) { create :partie, situation: situation, evaluation: evaluation2 }

    before { visit admin_situation_parties_path(situation) }

    it do
      expect(page).to have_content('evaluation 1')
      expect(page).to have_content('evaluation 2')
    end
  end
end
