# frozen_string_literal: true

FactoryBot.define do
  factory :questionnaire do
    libelle { 'Mon Questionnaire' }
    sequence(:nom_technique) { |n| "questionnaire_#{n}" }
  end
end
