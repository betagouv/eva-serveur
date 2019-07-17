# frozen_string_literal: true

class QuestionnaireQuestion < ApplicationRecord
  belongs_to :question

  acts_as_list scope: :questionnaire_id
end
