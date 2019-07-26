# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    libelle { 'Question' }
    intitule { 'Ma Question' }
  end

  factory :question_qcm do
    libelle { 'Question' }
  end
end
