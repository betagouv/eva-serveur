# frozen_string_literal: true

module Api
  class EvaluationsController < ActionController::API
    before_action :trouve_evaluation, only: %i[show update]

    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
    end

    def create
      evaluation = Evaluation.new(generateur_params_eval.params)
      if evaluation.save
        render json: evaluation, status: :created
      else
        erreurs = evaluation.errors.messages
        if generateur_params_eval.code_campagne_inconnu
          erreurs['campagne'] = [I18n.t('admin.evaluations.code_campagne_inconnu')]
        end
        render json: erreurs, status: :unprocessable_entity
      end
    end

    def update
      if @evaluation.update generateur_params_eval.params
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

    def generateur_params_eval
      @generateur_params_eval ||= GenerateurParamsEvaluation.new(params)
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
