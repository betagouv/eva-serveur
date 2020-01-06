# frozen_string_literal: true

module Api
  class EvenementsController < ActionController::API
    def create
      evenement = Evenement.new evenement_params.merge(partie: partie)

      if CreeEvenementAction.new(partie, evenement).call
        render json: evenement, status: :created
      else
        render json: evenement.errors.full_messages, status: 422
      end
    end

    private

    def evenement_params
      @evenement_params ||= EvenementParams.from(params)
    end

    def partie
      Partie.where(session_id: evenement_params[:session_id],
                   situation_id: situation_id,
                   evaluation_id: params[:evaluation_id]).first_or_create!
    end

    def situation_id
      nom_technique = params[:situation]
      situation = Situation.find_by(nom_technique: nom_technique)
      situation.id
    end
  end
end
