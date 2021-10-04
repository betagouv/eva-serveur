# frozen_string_literal: true

module Api
  class EvaluationsController < Api::BaseController
    def create
      evaluation = Evaluation.new(evaluation_params)
      if evaluation.save
        render partial: 'evaluation',
               locals: { evaluation: evaluation },
               status: :created
      else
        render json: evaluation.errors, status: :unprocessable_entity
      end
    end

    def update
      @evaluation = Evaluation.find(params[:id])
      if @evaluation.update evaluation_params
        render partial: 'evaluation',
               locals: { evaluation: @evaluation }
      else
        render json: @evaluation.errors, status: :unprocessable_entity
      end
    end

    private

    def evaluation_params
      params.permit(:nom, :code_campagne, :email, :telephone, :terminee_le)
    end
  end
end
