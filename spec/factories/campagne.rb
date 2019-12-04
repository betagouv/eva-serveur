# frozen_string_literal: true

FactoryBot.define do
  factory :campagne do
    libelle { 'Ma campagne' }
    sequence(:code) { |n| "CODE-#{n}" }
    compte
  end
end
