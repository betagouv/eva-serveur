# frozen_string_literal: true

module Api
  module Evaluations
    class CollectionsEvenementsController < Api::BaseController
      def create
        # params.permit(evenements: [:date, :donnees, :nom, :position, :session_id, :situation])
        if Evaluation.exists?(permit_params[:evaluation_id])
          PersisteCollectionEvenementsJob.perform_later(
            permit_params[:evaluation_id],
            permit_params[:evenements]
          )
          render json: {}, status: :created
        else
          render json: { message: I18n.t('admin.evaluations.inconnue') },
                 status: :unprocessable_entity
        end
      end

      private

      def permit_params
        @permit_params ||= params.permit(:evaluation_id,
                                         evenements: [
                                           :date,
                                           :nom,
                                           :position,
                                           :session_id,
                                           :situation,
                                           { donnees: {} }
                                         ])
      end

      def cree_evenements(evaluation_id, evenements)
        evenements.each do |parametres|
          parametres.merge!(evaluation_id: evaluation_id)
          FabriqueEvenement.new(parametres).call
        end
      end
    end
  end
end
