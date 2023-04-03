# frozen_string_literal: true

FactoryBot.define do
  factory :evaluation do
    nom { 'Roger' }
    campagne
    beneficiaire
    debutee_le { 1.hour.ago }

    trait :terminee do
      terminee_le { Time.current }
    end

    trait :avec_donnee_sociodemographique do
      after(:create) do |evaluation|
        create(:donnee_sociodemographique, evaluation: evaluation)
      end
    end

    trait :avec_mise_en_action do
      transient do
        effectuee { true }
        repondue_le { Time.zone.local(2023, 1, 1, 12, 0, 0) }
        remediation { nil }
        difficulte { nil }
      end

      after(:create) do |evaluation, evaluator|
        create(:mise_en_action, evaluation: evaluation)
        evaluation.mise_en_action.update(
          effectuee: evaluator.effectuee,
          repondue_le: evaluator.repondue_le,
          remediation: evaluator.remediation,
          difficulte: evaluator.difficulte
        )
      end
    end
  end
end
