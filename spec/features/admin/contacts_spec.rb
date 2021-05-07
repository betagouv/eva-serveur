# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Contacts', type: :feature do
  before(:each) { se_connecter_comme_superadmin }

  describe 'lister les contacts' do
    let(:structure) { create :structure, nom: 'Ma structure' }
    let(:compte) { create :compte, email: 'emailcompte@structure.com', structure: structure }
    let!(:contact) do
      create :contact, email: 'emailcontact@structure.com',
                       nom: 'Mon nom contact',
                       saisi_par: compte
    end

    before { visit admin_contacts_path }

    it do
      expect(page).to have_content 'Mon nom contact'
      expect(page).to have_content 'emailcontact@structure.com'
      expect(page).to have_content 'emailcompte@structure.com'
      expect(page).to have_content 'Ma structure'
    end
  end
end
