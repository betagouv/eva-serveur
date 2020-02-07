# frozen_string_literal: true

FactoryBot.define do
  factory :mise_en_action do
    elements_decouverts { true }
    recommandations_candidat { true }
    type_recommandation { :formation }
  end
end
