# frozen_string_literal: true

FactoryBot.define do
  factory :campagne do
    libelle { 'Ma campagne' }
    code { '123DB' }
    compte
  end
end
