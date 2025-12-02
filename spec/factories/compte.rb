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
    etape_inscription { :complet }

    trait :structure_avec_admin do
      structure { create(:structure, :avec_admin) }
    end
    trait :en_attente do
      statut_validation { :en_attente }
    end
    trait :acceptee do
      statut_validation { :acceptee }
    end
    trait :refusee do
      statut_validation { :refusee }
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
    end
    factory :compte_generique do
      role { 'compte_generique' }
    end

    factory :compte_pro_connect do
      role { 'conseiller' }
      structure { nil }
      statut_validation { :en_attente }
      id_pro_connect { 'id_pro_connect_123' }
      siret_pro_connect { '13002526500013' }
      etape_inscription { 'nouveau' }

      after(:create, &:assigne_preinscription)
    end
  end

  sequence :email do |n|
    "toto-#{n}@exemple.fr"
  end
end
