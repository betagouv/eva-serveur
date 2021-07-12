# frozen_string_literal: true

module Api
  class QuestionnairesController < Api::BaseController
    def show
      questionnaire = Questionnaire.includes(questions: %i[illustration_attachment choix])
                                   .find(params[:id])
      render json: questionnaire.questions
    end
  end
end
