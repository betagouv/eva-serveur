# frozen_string_literal: true

require 'rails_helper'

describe 'Session', type: :feature do
  describe 'Connexion Espace Pro' do
    context 'Quand tout va bien' do
      let!(:compte) { create :compte }

      it "Se connect à l'application" do
        connecte(compte)
        expect(page).to have_current_path(admin_dashboard_path)
      end
    end

    context "Quand le compte n'existe pas" do
      before do
        connecte_email email: 'invalid@email.com'
      end

      it "Renvoie un message d'erreur" do
        expect(page).to have_content('Email ou mot de passe incorrect')
      end
    end

    context 'Quand mon compte anlci a un mot de passe faible car les règles ont été remforcées' do
      let!(:compte) do
        compte = create :compte, role: :superadmin
        # rubocop:disable Rails/SkipsModelValidations
        compte.update_attribute(:password, '123')
        # rubocop:enable Rails/SkipsModelValidations
        compte
      end

      it "Refuse la connexion et renvoie un message d'erreur" do
        connecte(compte)
        expect(page).to have_current_path(new_compte_session_path)
        expect(page).to have_content("Votre mot de passe n'est pas conforme")
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

        context 'si je mets des espaces à la fin de mon email' do
          before do
            connecte_email email: "#{compte_non_confirme.email}     ",
                           password: compte_non_confirme.password
          end

          it do
            expect(page).to have_current_path(new_compte_confirmation_path)
          end
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
      let!(:compte_confirme) { create :compte, confirmed_at: Time.zone.now }

      it 'me connecte à mon espace pro' do
        connecte(compte_confirme)
        expect(page).to have_current_path(admin_dashboard_path)
      end
    end
  end

  describe 'Connexion Espace Jeu' do
    context 'Quand le code de campagne est invalide' do
      before do
        visit new_compte_session_path
        fill_in :code, with: 'invalide'
        click_on 'Lancer eva'
      end

      it "Renvoie un message d'erreur" do
        expect(page).to have_content(I18n.t('active_admin.devise.login.evaluations.code_invalide'))
      end
    end
  end
end
