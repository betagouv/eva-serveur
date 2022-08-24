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
      permit_params = params
                      .permit(:nom, :code_campagne, :terminee_le, :debutee_le,
                              condition_passation_attributes: %i[materiel_utilise modele_materiel
                                                                 nom_navigateur version_navigateur
                                                                 resolution_ecran])
      permit_params[:beneficiaire_attributes] = { nom: permit_params[:nom] }
      permit_params
    end
  end
end
