# frozen_string_literal: true

require 'rails_helper'

describe 'Structures', type: :feature do
  describe '#index liste les structures du même code code postal' do
    let!(:structure_paris) { create :structure, nom: 'MILO Paris', code_postal: '75012' }
    let!(:structure_lyon) { create :structure, nom: 'MILO Lyon', code_postal: '69000' }

    it do
      visit structures_path
      expect(page).to_not have_content 'MILO Paris'
      fill_in :code_postal, with: '75012'
      click_on 'chercher'
      expect(page).to have_content 'MILO Paris'
      expect(page).to_not have_content 'MILO Lyon'
    end
  end
end
