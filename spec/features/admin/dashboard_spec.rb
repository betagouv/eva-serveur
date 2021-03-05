# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Dashboard' do
  context 'En organisation' do
    before { connecte compte_organisation }
    let(:compte_organisation) { create :compte_organisation }

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

    describe 'Ajouter un contact' do
      before do
        visit admin_root_path
        fill_in :contact_nom, with: 'Nouveau Contact'
        fill_in :contact_email, with: 'nouveau@email.com'
        fill_in :contact_telephone, with: '06 12 34 56 78'
      end

      it do
        expect { click_on 'Ajouter' }.to(change { Contact.count })
        nouveau_contact = Contact.last
        expect(nouveau_contact.nom).to eq 'Nouveau Contact'
        expect(nouveau_contact.email).to eq 'nouveau@email.com'
        expect(nouveau_contact.telephone).to eq '06 12 34 56 78'
        expect(nouveau_contact.saisi_par).to eq compte_organisation
      end
    end
  end
end
