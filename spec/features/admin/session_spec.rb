# frozen_string_literal: true

require 'rails_helper'

describe 'Session', type: :feature do
  describe 'Connexion' do
    context "Quand le compte n'existe pas" do
      before do
        visit new_compte_session_path
        fill_in 'Email', with: 'invalid@email.com'
        click_on 'Se connecter'
      end
      it "Renvoie un message d'erreur" do
        expect(page).to have_content('Email ou mot de passe incorrect')
      end
    end

    context "Quand mon compte n'est pas confirmé" do
      context "Quand l'inscription est supérieure à 2 ans" do
        let!(:compte_non_confirme) do
          compte = create :compte, confirmed_at: nil
          compte.update(confirmation_sent_at: 3.years.ago)
          compte
        end

        it 'redirige vers la page de confirmation' do
          connecte(compte_non_confirme)
          expect(page).to have_current_path(new_compte_confirmation_path)
        end
      end

      context "Quand l'inscription est inférieure à 2 ans" do
        let!(:compte_non_confirme) do
          create :compte, confirmed_at: nil, confirmation_sent_at: Time.current
        end

        it 'redirige vers le tableau de bord' do
          connecte(compte_non_confirme)
          expect(page).to have_current_path(admin_dashboard_path)
        end
      end
    end

    context 'Quand mon compte est confirmé et existe' do
      let!(:compte_confirme) { create :compte, confirmed_at: Time.now }
      it 'me connecte à mon espace pro' do
        connecte(compte_confirme)
        expect(page).to have_current_path(admin_dashboard_path)
      end
    end
  end
end
