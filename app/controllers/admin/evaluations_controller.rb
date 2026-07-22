module Admin
  class EvaluationsController < ApplicationController
    before_action :authenticate_compte!

    def index
      if current_compte.utilisateur_evapro?
        redirect_to admin_evaluations_evapro_path
      else
        redirect_to admin_evaluations_eva_path
      end
    end

    def show
      evaluation = Evaluation.find(params[:id])

      if evaluation.is_a?(EvaluationEvapro)
        redirect_to admin_evaluation_evapro_path(evaluation)
      else
        redirect_to admin_evaluation_eva_path(evaluation)
      end
    end
  end
end
