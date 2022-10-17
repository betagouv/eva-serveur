# frozen_string_literal: true

require 'rails_helper'

describe 'Reset mot de passe', type: :feature do
  describe 'page envoie des instructions' do
    before do
      visit new_compte_confirmation_path
      click_on 'Renvoyer les instructions de confirmation'
    end

    it { expect(page.has_css?('#error_explanation')).to eq false }
  end

  describe 'page modification du mot de passe' do
    before do
      compte = create :compte
      raw_token, hashed_token = Devise.token_generator.generate(Compte, :reset_password_token)
      compte.update(reset_password_token: hashed_token, reset_password_sent_at: Time.now.utc)
      visit edit_compte_password_path(compte, reset_password_token: raw_token)

      click_on 'Valider mon nouveau mot de passe'
    end

    it { expect(page.has_css?('#error_explanation')).to eq false }
  end
end
