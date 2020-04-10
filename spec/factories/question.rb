# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    libelle { 'Question' }
    intitule { 'Ma Question' }
  end

  factory :question_qcm do
    libelle { 'Question QCM' }
  end

  factory :question_redaction_note do
    libelle { 'Question Redaction Note' }
    intitule { 'Ecrivez une note' }
  end
end
