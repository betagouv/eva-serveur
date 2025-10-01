FactoryBot.define do
  factory :questionnaire do
    libelle { 'Mon Questionnaire' }
    sequence(:nom_technique) { |n| "questionnaire_#{n}" }

    trait :livraison_avec_redaction do
      libelle { 'Livraison avec rédaction' }
      nom_technique { Questionnaire::LIVRAISON_AVEC_REDACTION }
    end

    trait :livraison_sans_redaction do
      libelle { 'Livraison sans rédaction' }
      nom_technique { Questionnaire::LIVRAISON_SANS_REDACTION }
    end

    trait :sociodemographique_autopositionnement do
      libelle { 'Sociodémographique et autopositionnement' }
      nom_technique { Questionnaire::SOCIODEMOGRAPHIQUE_AUTOPOSITIONNEMENT }
    end

    trait :sociodemographique do
      libelle { 'Sociodémographique' }
      nom_technique { Questionnaire::SOCIODEMOGRAPHIQUE }
    end

    trait :autopositionnement do
      libelle { 'Autopositionnement' }
      nom_technique { Questionnaire::AUTOPOSITIONNEMENT }
    end
  end
end
