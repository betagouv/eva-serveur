# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    libelle { 'Question' }
    sequence(:nom_technique) { |n| "question-#{n}" }

    transient do
      transcription_ecrit { 'Ma question ?' }
    end

    after(:create) do |question, evaluator|
      create(:transcription, question_id: question.id,
                             ecrit: evaluator.transcription_ecrit)
    end
  end

  factory :question_qcm do
    libelle { 'Question QCM' }
    sequence(:nom_technique) { |n| "question-qcm-#{n}" }
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
end
