# frozen_string_literal: true

FactoryBot.define do
  factory :compte do
    email
    nom { 'Nom' }
    prenom { 'Prénom' }
    password { 'Password78901$' }
    role { 'superadmin' }
    statut_validation { :acceptee }
    cgu_acceptees { true }
    email_bienvenue_envoye { true }
    structure factory: :structure_locale

    trait :structure_avec_admin do
      structure { create(:structure, :avec_admin) }
    end

    factory :compte_superadmin do
      role { 'superadmin' }
    end
    factory :compte_charge_mission_regionale do
      role { 'charge_mission_regionale' }
    end
    factory :compte_admin do
      role { 'admin' }
    end
    factory :compte_conseiller do
      role { 'conseiller' }
      trait :en_attente do
        statut_validation { :en_attente }
      end
      trait :acceptee do
        statut_validation { :acceptee }
      end
      trait :refusee do
        statut_validation { :refusee }
      end
    end
    factory :compte_generique do
      role { 'compte_generique' }
    end
  end

  sequence :email do |n|
    "toto-#{n}@exemple.fr"
  end
end
