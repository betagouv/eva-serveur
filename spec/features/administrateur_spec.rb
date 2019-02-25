# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Administrateur', type: :feature do
  let(:administrateur) { create :administrateur, email: 'administrateur@exemple.fr' }

  context "en tant qu'administrateur", focus: true do
    before(:each) { se_connecter_comme_administrateur }

    it 'je peux accèder au BO' do
      expect(page).to have_content 'Dashboard'
    end
  end
end
