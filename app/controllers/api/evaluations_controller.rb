# frozen_string_literal: true

module Api
  class EvaluationsController < ActionController::API
    def create
      evaluation = Evaluation.new(EvaluationParams.from(params))

      if evaluation.save
        render json: evaluation, status: :created
      else
        render json: evaluation.errors.full_messages, status: 422
      end
    end
  end
end
