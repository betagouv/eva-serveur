# frozen_string_literal: true

module Api
  class EvaluationsController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound do
      render status: :not_found
    end

    def create
      evaluation = Evaluation.new(EvaluationParams.from(params))
      if evaluation.save
        render json: evaluation, status: :created
      else
        render json: evaluation.errors, status: 422
      end
    end

    def show
      evaluation = Evaluation.find(params[:id])

      questions = evaluation.campagne.questionnaire&.questions || []

      render json: { questions: questions }
    end
  end
end
