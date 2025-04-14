# frozen_string_literal: true

module QuestionHelper
  def type_clic(question)
    question.clic_multiple? ? "multiple" : "simple"
  end
end
