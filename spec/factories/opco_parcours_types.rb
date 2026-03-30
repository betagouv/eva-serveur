# frozen_string_literal: true

FactoryBot.define do
  factory :opco_parcours_type do
    association :opco, factory: :opco
    association :parcours_type, factory: :parcours_type
  end
end
