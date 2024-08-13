# frozen_string_literal: true

module Api
  class QuestionnairesController < Api::BaseController
    def show
      questionnaire = Questionnaire.find(params[:id])
      render json: questionnaire.questions.includes([:choix])
    end
  end
end
