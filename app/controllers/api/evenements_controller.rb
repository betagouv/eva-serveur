# frozen_string_literal: true

module Api
  class EvenementsController < Api::BaseController
    def create
      evenement = FabriqueEvenement.new(params).call
      if evenement.persisted?
        render json: evenement, status: :created
      else
        render json: evenement.errors.full_messages, status: :unprocessable_entity
      end
    end
  end
end
