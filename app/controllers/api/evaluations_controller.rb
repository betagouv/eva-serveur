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

    def map_descriptions(competences)
      competences.map do |identifiant|
        {
          id: identifiant,
          nom: I18n.t("#{identifiant}.nom",
                      scope: 'admin.evaluations.restitution_competence'),
          description: I18n.t("#{identifiant}.description",
                              scope: 'admin.evaluations.restitution_competence'),
          picto: ActionController::Base.helpers.asset_url(identifiant)
        }
      end
    end

    def show
      evaluation = Evaluation.find(params[:id])
      situations = evaluation.campagne.situations
      questions = evaluation.campagne.questionnaire&.questions || []
      competences = []
      if evaluation.campagne.affiche_competences_fortes
        competences = map_descriptions(FabriqueRestitution
                                        .restitution_globale(evaluation)
                                        .competences)
      end
      render json: { questions: questions, situations: situations, competences_fortes: competences }
    end
  end
end
