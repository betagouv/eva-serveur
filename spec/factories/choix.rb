# frozen_string_literal: true

FactoryBot.define do
  factory :choix do
    trait :bon do
      type_choix { :bon }
      intitule { 'bon choix' }
    end

    trait :mauvais do
      type_choix { :mauvais }
      intitule { 'mauvais choix' }
    end

    trait :abstention do
      type_choix { :abstention }
      intitule { 'choix abstention' }
    end
  end
end
