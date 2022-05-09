# frozen_string_literal: true

FactoryBot.define do
  factory :questionnaire do
    libelle { 'Mon Questionnaire' }
    sequence(:nom_technique) { |n| "questionnaire_#{n}" }

    trait :livraison_avec_redaction do
      libelle { 'Livraison (MES illettrisme 2)' }
      nom_technique { Questionnaire::LIVRAISON_AVEC_REDACTION }
    end

    trait :livraison_sans_redaction do
      libelle { 'Livraison sans rédaction' }
      nom_technique { Questionnaire::LIVRAISON_SANS_REDACTION }
    end
  end
end
