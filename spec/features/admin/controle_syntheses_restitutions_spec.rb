# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Controle synthèses restitutions', type: :feature do
  context 'ouvrir la page de controle' do
    before { visit admin_controle_syntheses_restitutions_path }

    it "l'affiche sans erreur" do
      expect(page).to have_http_status(200)
    end
  end
end
