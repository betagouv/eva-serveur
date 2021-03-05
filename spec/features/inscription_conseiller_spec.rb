# frozen_string_literal: true

require 'rails_helper'

describe 'Création de compte conseiller', type: :feature do
  before do
    create :structure, nom: 'Ma structure'
    visit new_compte_registration_path
    fill_in :compte_email, with: 'monemail@eva.fr'
    fill_in :compte_password, with: 'Pass123'
    fill_in :compte_password_confirmation, with: 'Pass123'
    select 'Ma structure'
  end

  it do
    expect { click_on "S'inscrire" }.to change(Compte, :count).by 1

    nouveau_compte = Compte.find_by email: 'monemail@eva.fr'
    expect(nouveau_compte.validation_en_attente?).to be true
  end
end
