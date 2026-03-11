# frozen_string_literal: true

FactoryBot.define do
  factory :invitation do
    structure factory: :structure_locale
    association :invitant, factory: :compte_admin
    email_destinataire { "invite@test.com" }
    statut { "en_cours" }
    role { Compte::ROLE_PAR_DEFAUT }

    trait :acceptee do
      statut { "acceptee" }
    end

    trait :annulee do
      statut { "annulee" }
    end
  end
end
