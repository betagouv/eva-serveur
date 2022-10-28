# frozen_string_literal: true

FactoryBot.define do
  factory :donnee_sociodemographique do
    age { 30 }
    genre { 'femme' }
    dernier_niveau_etude { 'bac' }
    evaluation
  end
end
