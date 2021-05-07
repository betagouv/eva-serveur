# frozen_string_literal: true

FactoryBot.define do
  factory :compte do
    email
    nom { 'Nom' }
    prenom { 'Prénom' }
    password { 'password' }
    role { 'superadmin' }
    statut_validation { :acceptee }

    factory :compte_superadmin do
      role { 'superadmin' }
    end
    factory :compte_admin do
      role { 'admin' }
    end
    factory :compte_conseiller do
      role { 'conseiller' }
    end
    factory :compte_generique do
      role { 'compte_generique' }
    end
    structure
  end

  sequence :email do |n|
    "superadmin-#{n}@exemple.fr"
  end
end
