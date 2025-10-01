require 'rails_helper'

describe 'Admin - Controle synthèses restitutions', type: :feature do
  context 'ouvrir la page de controle' do
    before { visit admin_controle_syntheses_restitutions_path }

    it "l'affiche sans erreur" do
      message_litteratie = 'Il semble que vous avez d’importantes difficultés en production écrite.'
      message_numeratie = 'Votre score indique une maîtrise des nombres entiers.'

      expect(page).to have_http_status(200)
      expect(page).to have_content('Production écrite')
      expect(page).to have_content(message_litteratie)
      expect(page).to have_content('Se repérer dans l’univers des nombres')
      expect(page).to have_content(message_numeratie)
    end
  end
end
