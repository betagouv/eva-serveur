# frozen_string_literal: true

module Api
  class EvaluationsController < ActionController::API
    before_action :trouve_evaluation, only: %i[show update]

    rescue_from ActiveRecord::RecordNotFound do
      render status: :not_found
    end

    def create
      evaluation = Evaluation.new(EvaluationParams.from(params))
      if evaluation.save
        render json: evaluation, status: :created
      else
        render json: evaluation.errors, status: :unprocessable_entity
      end
    end

    def update
      if @evaluation.update EvaluationParams.from(params)
        render json: @evaluation
      else
        render json: @evaluation.errors, status: :unprocessable_entity
      end
    end

    def show
      @situations = @evaluation.campagne.situations_configurees
      @questions = @evaluation.campagne.questionnaire&.questions || []
      @competences = []

      return unless @evaluation.campagne.affiche_competences_fortes

      @competences = map_descriptions(FabriqueRestitution
                                      .restitution_globale(@evaluation)
                                      .competences)
    end

    private

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
