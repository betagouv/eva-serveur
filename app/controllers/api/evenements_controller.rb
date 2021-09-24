# frozen_string_literal: true

module Api
  class EvenementsController < Api::BaseController
    def create
      if cree_evenement
        render json: @evenement, status: :created
      else
        render json: @evenement.errors.full_messages, status: :unprocessable_entity
      end
    end

    def self.cree_partie(session_id, nom_technique_situation, evaluation_id)
      situation = Situation.find_by(nom_technique: nom_technique_situation)
      Partie.where(session_id: session_id,
                   situation: situation,
                   evaluation_id: evaluation_id).first_or_create!
    end

    private

    def cree_evenement
      resultat = false
      ActiveRecord::Base.transaction do
        @evenement = Evenement.new evenement_params.merge(partie: partie)
        resultat = CreeEvenementAction.new(partie, @evenement).call
        raise ActiveRecord::Rollback unless resultat
      end
      resultat
    end

    def evenement_params
      @evenement_params ||= EvenementParams.from(params)
    end

    def partie
      @partie ||= self.class.cree_partie(
        params[:session_id], params[:situation], params[:evaluation_id]
      )
    end
  end
end
