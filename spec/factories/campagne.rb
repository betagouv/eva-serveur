# frozen_string_literal: true

FactoryBot.define do
  factory :campagne do
    sequence(:libelle) { |n| "Ma campagne #{n}" }
    sequence(:code) { |n| "CODE#{n}" }
    association :compte, factory: :compte_admin
    parcours_type
    type_programme { :diagnostic }

    trait :avec_situations_configurations do
      situations_configurations { build_list(:situation_configuration, 1) }
    end
  end
end
