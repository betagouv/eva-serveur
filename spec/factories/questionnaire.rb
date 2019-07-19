# frozen_string_literal: true

FactoryBot.define do
  factory :questionnaire do
    libelle { 'Mon Questionnaire' }

    transient do
      questions { [] }
    end

    after(:create) do |questionnaire, evaluator|
      questionnaire.questionnaires_questions = evaluator.questions.map do |question|
        QuestionnaireQuestion.new(question: question)
      end
    end
  end
end
