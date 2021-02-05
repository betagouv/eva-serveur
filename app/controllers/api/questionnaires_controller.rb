# frozen_string_literal: true

module Api
  class QuestionnairesController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
    end

    def show
      questionnaire = Questionnaire.find(params[:id])
      render json: questionnaire.questions
    end
  end
end
