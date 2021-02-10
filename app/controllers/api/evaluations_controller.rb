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
      @competences = []

      return unless @campagne.affiche_competences_fortes?

      @competences = map_descriptions(FabriqueRestitution
                                      .restitution_globale(@evaluation)
                                      .competences)
    end

    private

    def evaluation_params
      params.permit(:nom, :code_campagne, :email, :telephone)
    end

    def trouve_evaluation
      @evaluation = Evaluation.find(params[:id])
    end

    def map_descriptions(competences)
      competences.map do |identifiant|
        {
          id: identifiant,
          nom: I18n.t("#{identifiant}.nom",
                      scope: 'admin.evaluations.restitution_competence'),
          description: I18n.t("#{identifiant}.description",
                              scope: 'admin.evaluations.restitution_competence'),
          picto: ActionController::Base.helpers.asset_url("#{identifiant}.svg")
        }
      end
    end
  end
end
