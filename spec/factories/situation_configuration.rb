# frozen_string_literal: true

FactoryBot.define do
  factory :situation_configuration do
    association :situation

    trait :numeratie do
      association :situation, factory: :situation_numeratie
    end

    trait :litteratie do
      association :situation, factory: :situation_litteratie
    end
  end
end
