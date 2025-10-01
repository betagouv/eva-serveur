require 'rails_helper'

describe 'Reset mot de passe', type: :feature do
  describe 'page envoie des instructions' do
    before do
      visit new_compte_confirmation_path
      click_on 'Renvoyer les instructions de confirmation'
    end

    it { expect(page.has_css?('#error_explanation')).to be false }
  end

  describe 'page modification du mot de passe' do
    let(:compte) { create :compte }

    context 'avec un token valide' do
      before do
        raw_token, hashed_token = Devise.token_generator.generate(Compte, :reset_password_token)
        compte.update(reset_password_token: hashed_token, reset_password_sent_at: Time.now.utc)
        visit edit_compte_password_path(compte, reset_password_token: raw_token)

        click_on 'Valider mon nouveau mot de passe'
      end

      it { expect(page.has_css?('#error_explanation')).to be false }
    end

    context 'avec un token invalide' do
      before do
        visit edit_compte_password_path(compte, reset_password_token: 'invalide')
      end

      it do
        texte = I18n.t('active_admin.devise.reset_password.saisir_a_nouveau')
        expect(page).to have_content(texte)
      end

      it do
        texte = I18n.t('active_admin.devise.passwords.edit.token_invalide')
        expect(page).to have_content(texte)
      end
    end
  end
end
