FactoryBot.define do
  factory :questionnaire_question do
    question_id { create(:question).id }
    questionnaire_id { create(:questionnaire).id }
  end
end
