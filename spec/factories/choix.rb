# frozen_string_literal: true

FactoryBot.define do
  factory :choix do
    nom_technique { 'nom_technique_choix' }

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

    trait :avec_audio do
      audio { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/alcoolique.mp3')) }
    end

    trait :avec_illustration do
      illustration do
        Rack::Test::UploadedFile.new(Rails.root.join('spec/support/programme_tele.png'))
      end
    end
  end
end
