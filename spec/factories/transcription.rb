# frozen_string_literal: true

FactoryBot.define do
  factory :transcription do
    ecrit { 'Ma question' }
    categorie { :intitule }
    association :question
  end
end
