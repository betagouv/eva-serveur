# frozen_string_literal: true

module Api
  module Evaluations
    class FinsController < Api::BaseController
      def create
        @competences = []

        evaluation = Evaluation.find(params[:evaluation_id])

        restitution_globale = FabriqueRestitution.restitution_globale(evaluation)

        restitution_globale.persiste

        return unless evaluation.campagne.affiche_competences_fortes?

        @competences = map_descriptions(restitution_globale.competences)
      end

      private

      def map_descriptions(competences)
        competences.map do |identifiant|
          {
            nom_technique: identifiant,
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
end
