# frozen_string_literal: true

FactoryBot.define do
  factory :evaluation do
    nom { 'Roger' }
    campagne
    debutee_le { Time.current }
  end
end
