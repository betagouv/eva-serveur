# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    libelle { 'Question' }
    sequence(:nom_technique) { |n| "question-#{n}" }

    transient do
      transcription_ecrit { 'Ma question ?' }
    end

    trait :numeratie_niveau1 do
      nom_technique { 'N1Prn2' }
    end

    trait :numeratie_niveau1_rattrapage do
      nom_technique { 'N1Rrn2' }
    end

    trait :numeratie_niveau2 do
      nom_technique { 'N2Pon1' }
    end

    trait :numeratie_niveau2_rattrapage do
      nom_technique { 'N2Ron1' }
    end

    trait :numeratie_niveau3 do
      nom_technique { 'N3Pum1' }
    end

    trait :numeratie_niveau3_rattrapage do
      nom_technique { 'N3Rum1' }
    end

    trait :livraison do
      nom_technique { 'multiplication_niveau2' }
    end

    after(:create) do |question, evaluator|
      create(:transcription, question_id: question.id,
                             ecrit: evaluator.transcription_ecrit)
    end
  end

  factory :question_qcm do
    libelle { 'Question QCM' }
    sequence(:nom_technique) { |n| "question-qcm-#{n}" }

    trait :livraison do
      nom_technique { 'multiplication_niveau2' }
    end

    trait :metacompetence_ccf do
      nom_technique { 'connaissance_et_comprehension_1' }
    end
  end

  factory :question_saisie do
    libelle { 'Question Redaction Note' }
    sequence(:nom_technique) { |n| "question-saisie-#{n}" }

    transient do
      transcription_ecrit { 'Ecrivez une note' }
    end

    after(:create) do |question, evaluator|
      create(:transcription, question_id: question.id, ecrit: evaluator.transcription_ecrit)
    end
  end

  factory :question_clic_dans_image do
    libelle { 'Question clic dans image' }
    sequence(:nom_technique) { |n| "question-clic-dans-image-#{n}" }

    trait :avec_images do
      illustration do
        Rack::Test::UploadedFile.new(Rails.root.join('spec/support/programme_tele.png'))
      end
      zone_cliquable do
        Rack::Test::UploadedFile.new(Rails.root.join('spec/support/zone-clicable-valide.svg'))
      end
      image_au_clic do
        Rack::Test::UploadedFile.new(Rails.root.join('spec/support/zone-clicable-valide.svg'))
      end
    end
  end

  factory :question_glisser_deposer do
    libelle { 'Question glisser deposer' }
    sequence(:nom_technique) { |n| "question-glissser-deposer-#{n}" }
    orientation { 'vertical' }
    trait :avec_images do
      illustration do
        Rack::Test::UploadedFile.new(Rails.root.join('spec/support/programme_tele.png'))
      end
      zone_depot do
        Rack::Test::UploadedFile.new(Rails.root.join('spec/support/N1Pse1-zone-depot-valide.svg'))
      end
    end
  end

  factory :question_sous_consigne do
    libelle { 'Question sous consigne' }
    sequence(:nom_technique) { |n| "question-sous-consigne-#{n}" }
  end

  factory :question_clic_dans_texte do
    libelle { 'Question clic dans texte' }
    sequence(:nom_technique) { |n| "question-clic-dans-texte-#{n}" }
  end
end
