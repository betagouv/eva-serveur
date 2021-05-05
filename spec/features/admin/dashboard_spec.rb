# frozen_string_literal: true

require 'rails_helper'

describe 'Dashboard', type: :feature do
  let(:ma_structure) { create :structure }
  let!(:compte) { create :compte_administrateur, structure: ma_structure }
  before { connecte(compte) }

  context 'quand il y a des comptes en attente pour ma structures' do
    before { create :compte, statut_validation: :en_attente, structure: ma_structure }
    it "affiche un message d'alerte" do
      visit admin_path
      expect(page).to have_content("Des demandes d'accès sont en attente de validation.")
    end
  end

  context "quand il n'y a pas de compte en attente pour ma structures" do
    it "n'affiche pas de message d'alerte" do
      visit admin_path
      expect(page).not_to have_content("Des demandes d'accès sont en attente de validation.")
    end
  end

  context 'quand mon compte est un compte générique' do
    let!(:compte) { create :compte_generique, structure: ma_structure }

    it "affiche un message d'incitation à créer un compte personnel" do
      visit admin_path
      expect(page).to have_content(
        'Nous déconseillons de partager un accès, vous pouvez créer votre compte personnel ici'
      )
    end
  end
end
