# frozen_string_literal: true

FactoryBot.define do
  factory :transcription do
    ecrit { 'Ma question' }
    categorie { :intitule }
    association :question

    trait :avec_audio do
      audio { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/alcoolique.mp3')) }
    end
  end
end
