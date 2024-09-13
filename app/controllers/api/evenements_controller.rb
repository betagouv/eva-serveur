# frozen_string_literal: true

module Api
  class EvenementsController < Api::BaseController
    def create
      evenement = FabriqueEvenement.new(permit_params).call
      if evenement.blank?
        logger.warn "Echec recherche partie, evenement ignoré : #{permit_params}"
        render json: {}, status: :ok
      elsif evenement.persisted?
        render json: evenement, status: :created
      else
        render json: evenement.errors.full_messages, status: :unprocessable_entity
      end
    end

    private

    def permit_params
      @permit_params ||= params.permit(
        :date,
        :nom,
        :session_id,
        :position,
        :situation,
        :evaluation_id,
        { donnees: {} }
      )
    end
  end
end
