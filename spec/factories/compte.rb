# frozen_string_literal: true

FactoryBot.define do
  factory :compte, aliases: [:compte_admin] do
    email
    nom { 'Nom' }
    prenom { 'Prénom' }
    password { 'password' }
    role { 'administrateur' }
    statut_validation { :acceptee }

    factory :compte_administrateur do
      role { 'administrateur' }
    end
    factory :compte_organisation do
      role { 'organisation' }
    end
    factory :compte_generique do
      role { 'compte_generique' }
    end
    structure
  end

  sequence :email do |n|
    "administrateur-#{n}@exemple.fr"
  end
end
