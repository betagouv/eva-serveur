# frozen_string_literal: true

module Api
  class EvaluationsController < ActionController::API
    before_action :trouve_evaluation, only: %i[show update]

    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
    end

    def create
      evaluation = Evaluation.new(evaluation_params)
      if evaluation.save
        render json: evaluation, status: :created
      else
        render json: evaluation.errors, status: :unprocessable_entity
      end
    end

    def update
      if @evaluation.update evaluation_params
        render json: @evaluation
      else
        render json: @evaluation.errors, status: :unprocessable_entity
      end
    end

    def show
      @campagne = @evaluation.campagne
      @questions = @campagne.questionnaire&.questions || []
    end

    private

    def evaluation_params
      params.permit(:nom, :code_campagne, :email, :telephone)
    end

    def trouve_evaluation
      @evaluation = Evaluation.find(params[:id])
    end
  end
end
