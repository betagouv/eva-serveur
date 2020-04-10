# frozen_string_literal: true

FactoryBot.define do
  factory :choix do
    trait :bon do
      type_choix { :bon }
      intitule { 'bon choix' }
    end
  end
end
