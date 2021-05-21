# frozen_string_literal: true

module Api
  class EvenementsController < Api::BaseController
    def create
      evenement = Evenement.new evenement_params.merge(partie: partie)

      if CreeEvenementAction.new(partie, evenement).call
        render json: evenement, status: :created
      else
        render json: evenement.errors.full_messages, status: :unprocessable_entity
      end
    end

    private

    def evenement_params
      @evenement_params ||= EvenementParams.from(params)
    end

    def partie
      situation = Situation.find_by(nom_technique: params[:situation])
      Partie.where(session_id: evenement_params[:session_id],
                   situation_id: situation,
                   evaluation_id: params[:evaluation_id]).first_or_create!
    end
  end
end
