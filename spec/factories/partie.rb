# frozen_string_literal: true

FactoryBot.define do
  factory :partie do
    session_id { SecureRandom.uuid }
    evaluation
    association :situation, factory: [ :situation_livraison ]
  end
end
