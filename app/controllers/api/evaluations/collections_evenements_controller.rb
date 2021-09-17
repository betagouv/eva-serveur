# frozen_string_literal: true

module Api
  module Evaluations
    class CollectionsEvenementsController < Api::BaseController
      def create
        @evaluation = Evaluation.find(params[:evaluation_id])
        Evenement.create(evenements_params)
        render json: {}, status: :created
      end

      private

      def evenements_params
        params[:evenements].map do |evenement|
          EvenementParams.from(evenement).merge(partie: partie(evenement))
        end
      end

      def partie(evenement)
        situation = Situation.find_by(nom_technique: evenement[:situation])
        Partie.where(session_id: evenement[:session_id],
                     situation_id: situation,
                     evaluation_id: @evaluation.id).first_or_create!
      end
    end
  end
end
