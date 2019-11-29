# frozen_string_literal: true

module Api
  class EvenementsController < ActionController::API
    def create
      @evenement = partie.evenements.new(evenement_params)
      if @evenement.save
        render json: @evenement, status: :created
      else
        render json: @evenement.errors.full_messages, status: 422
      end
    end

    private

    def evenement_params
      @evenement_params ||= EvenementParams.from(params)
    end

    def partie
      Partie.where(session_id: evenement_params[:session_id],
                   situation_id: evenement_params[:situation_id],
                   evaluation_id: evenement_params[:evaluation_id]).first_or_create!
    end
  end
end
