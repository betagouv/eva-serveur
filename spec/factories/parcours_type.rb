# frozen_string_literal: true

FactoryBot.define do
  factory :parcours_type do
    sequence(:libelle) { |n| "Parcours type ##{n}" }
    sequence(:nom_technique) { |n| "parcours_type_#{n}" }
    duree_moyenne { '1 heure' }
  end
end
