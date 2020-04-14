# frozen_string_literal: true

FactoryBot.define do
  factory :partie do
    session_id { '07319b2485be9ac4850664cd47cede38' }
    evaluation
    association :situation, factory: [:situation_livraison]
  end
end
