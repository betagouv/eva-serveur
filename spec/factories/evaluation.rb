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
  end
end
