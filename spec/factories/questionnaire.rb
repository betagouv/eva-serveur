# frozen_string_literal: true

FactoryBot.define do
  factory :questionnaire do
    libelle { 'Mon Questionnaire' }
    questions { [{}] }
  end
end
