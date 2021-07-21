# frozen_string_literal: true

module Api
  class QuestionnairesController < Api::BaseController
    def show
      questionnaire = Questionnaire.includes(questions: { illustration_attachment: :blob })
                                   .find(params[:id])
      render json: questionnaire.questions
    end
  end
end
