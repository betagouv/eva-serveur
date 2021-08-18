# frozen_string_literal: true

module Api
  class EvaluationsController < Api::BaseController
    before_action :trouve_evaluation, only: :show

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

    def show
      @campagne = @evaluation.campagne
      @questions = @campagne.questionnaire&.questions || []
    end

    private

    def evaluation_params
      params.permit(:nom, :code_campagne, :email, :telephone)
    end

    def trouve_evaluation
      @evaluation = Evaluation.includes(
        campagne: {
          situations_configurations: [:questionnaire,
                                      { situation: %i[questionnaire questionnaire_entrainement] }]
        }
      ).find(params[:id])
    end
  end
end
