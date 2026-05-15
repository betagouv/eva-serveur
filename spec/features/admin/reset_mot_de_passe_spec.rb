require 'rails_helper'

describe 'Reset mot de passe', type: :feature do
  describe 'page envoie des instructions' do
    before do
      visit new_compte_confirmation_path
      click_on 'Renvoyer les instructions de confirmation'
    end

    it { expect(page.has_css?('#error_explanation')).to be false }
  end

  describe 'mot de passe oublié (sans lien)' do
    let(:i18n_request_email) { 'active_admin.devise.reset_password.request_email' }

    it 'affiche la demande d’e-mail avec bouton désactivé tant que l’e-mail est vide' do
      visit new_compte_password_path

      expect(page).to have_content(I18n.t(:title, scope: i18n_request_email))
      expect(page).to have_content(I18n.t(:titre_carte, scope: i18n_request_email))
      expect(page).to have_css('.texte-intro')
      expect(page).to have_css('.carte-v2')
      expect(page).to have_field(I18n.t(:email_label, scope: i18n_request_email))
      expect(page).not_to have_css('.fr-alert--info')
      expect(page).not_to have_css('.fr-alert--error')
      expect(page).to have_button(I18n.t(:submit, scope: i18n_request_email), disabled: true)
    end
  end

  describe 'page modification du mot de passe' do
    let(:compte) do
      create(:compte, password: 'AncienMotDePasse12$', password_confirmation: 'AncienMotDePasse12$')
    end
    let(:i18n_passwords_edit) { 'active_admin.devise.passwords.edit' }
    let(:raw_token) do
      raw_token, hashed_token = Devise.token_generator.generate(Compte, :reset_password_token)
      compte.update(reset_password_token: hashed_token, reset_password_sent_at: Time.zone.now.utc)
      raw_token
    end

    context 'avec un token valide (première ouverture du lien)' do
      it 'affiche l’alerte info et le formulaire de nouveau mot de passe' do
        visit edit_compte_password_path(compte, reset_password_token: raw_token)

        expect(page).to have_content(I18n.t('active_admin.devise.change_password.title'))
        expect(page).to have_css('.fr-alert--info')
        expect(page).to have_content(I18n.t(:alert_titre, scope: i18n_passwords_edit))
        expect(page).to have_content(I18n.t(:alert_description, scope: i18n_passwords_edit))
        expect(page).to have_css('.carte-v2')
        expect(page).not_to have_css('.texte-intro')
        expect(page).to have_field(I18n.t('active_admin.devise.password.title'))
        expect(page).to have_field(I18n.t('active_admin.devise.password_confirmation.title'))
        expect(page).to have_content(I18n.t(:champs_obligatoires, scope: i18n_passwords_edit))
        expect(page).to have_button(I18n.t(:submit, scope: i18n_passwords_edit))
      end

      it 'affiche une erreur quand les mots de passe ne correspondent pas' do
        visit edit_compte_password_path(compte, reset_password_token: raw_token)

        fill_in I18n.t('active_admin.devise.password.title'), with: 'azerty123'
        fill_in I18n.t('active_admin.devise.password_confirmation.title'), with: 'different123'
        click_on I18n.t(:submit, scope: i18n_passwords_edit)

        expect(page).to have_content('ne concorde pas avec')
      end

      it 'ne change pas le mot de passe quand il ne respecte pas les règles' do
        visit edit_compte_password_path(compte, reset_password_token: raw_token)

        fill_in I18n.t('active_admin.devise.password.title'), with: '1234567'
        fill_in I18n.t('active_admin.devise.password_confirmation.title'), with: '1234567'
        click_on I18n.t(:submit, scope: i18n_passwords_edit)

        expect(compte.reload.valid_password?('1234567')).to be false
      end
    end

    context 'avec un token invalide (deuxième ouverture du lien)' do
      let(:i18n_invalid_link) { 'active_admin.devise.reset_password.invalid_link' }

      before do
        visit edit_compte_password_path(compte, reset_password_token: 'invalide')
      end

      it 'affiche une alerte erreur et le formulaire de renvoi d’e-mail' do
        expect(page).to have_css('.fr-alert--error')
        expect(page).to have_content(I18n.t(:alert_titre, scope: i18n_invalid_link))
        expect(page).to have_content(I18n.t(:alert_description, scope: i18n_invalid_link))
        expect(page).to have_css('.carte-v2')
        expect(page).not_to have_css('.texte-intro')
        expect(page).to have_field(I18n.t(:email_label, scope: i18n_invalid_link))
        expect(page).to have_button(I18n.t(:submit, scope: i18n_invalid_link), disabled: true)
      end

      it 'permet de naviguer vers la connexion' do
        expect(page).to have_link(
          I18n.t(:lien_accueil, scope: i18n_invalid_link),
          href: new_compte_session_path
        )
      end
    end
  end
end
