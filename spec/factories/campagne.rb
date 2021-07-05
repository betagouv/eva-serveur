# frozen_string_literal: true

FactoryBot.define do
  factory :campagne do
    libelle { 'Ma campagne' }
    sequence(:code) { |n| "CODE#{n}" }
    association :compte, factory: :compte_conseiller
    parcours_type
  end
end
