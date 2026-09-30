# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Eva::Devise::RegistrationsController#create", type: :request do
  let!(:structure) { create(:structure_locale, :avec_admin) }
  let(:parametres) do
    { email: "nouveau@exemple.fr", password: "Password78901$",
      password_confirmation: "Password78901$", prenom: "Nouveau", nom: "Compte",
      structure_id: structure.id, cgu_acceptees: true }
  end

  it "ignore le rôle et le statut de validation envoyés" do
    post compte_registration_path,
         params: { compte: parametres.merge(role: "superadmin", statut_validation: "acceptee") }

    compte = Compte.find_by(email: "nouveau@exemple.fr")
    expect(compte.role).to eq "conseiller"
    expect(compte).to be_validation_en_attente
  end
end
