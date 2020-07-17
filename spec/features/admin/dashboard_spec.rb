# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Dashboard' do
  context 'En organisation' do
    before { connecte compte_organisation }
    let(:compte_organisation) { create :compte, role: 'organisation' }

    describe 'Lister mes contacts' do
      let!(:contact_autre) do
        create :contact, nom: 'Monsieur Absent',
                         saisi_par: create(:compte)
      end
      let!(:contact_organisation) do
        create :contact, nom: 'Monsieur Plus',
                         email: 'monsieur@plus.com',
                         saisi_par: compte_organisation
      end

      before { visit admin_root_path }
      it do
        expect(page).to have_content 'Monsieur Plus (monsieur@plus.com)'
        expect(page).to_not have_content 'Monsieur Absent'
      end
    end
  end
end
