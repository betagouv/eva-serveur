# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    libelle { 'Question' }
    nom_technique { 'question' }

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
    nom_technique { 'question-qcm' }
  end

  factory :question_saisie do
    libelle { 'Question Redaction Note' }
    nom_technique { 'question-redaction-note' }

    transient do
      transcription_ecrit { 'Ecrivez une note' }
    end

    after(:create) do |question, evaluator|
      create(:transcription, question_id: question.id, ecrit: evaluator.transcription_ecrit)
    end
  end
end
