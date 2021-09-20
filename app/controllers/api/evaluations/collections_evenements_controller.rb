# frozen_string_literal: true

module Api
  module Evaluations
    class CollectionsEvenementsController < Api::BaseController
      def create
        @evaluation = Evaluation.find(params[:evaluation_id])
        @parties = cree_parties
        Evenement.create(evenements_params)
        render json: {}, status: :created
      end

      private

      def evenements_params
        params[:evenements].map do |evenement|
          partie = @parties[evenement[:situation]]
          EvenementParams.from(evenement).merge(partie: partie)
        end
      end

      def cree_parties
        params[:evenements]
          .group_by { |evenement| evenement[:situation] }
          .transform_values do |evenements|
            partie(evenements.first)
          end
      end

      def partie(evenement)
        EvenementsController.cree_partie(evenement[:session_id],
                                         evenement[:situation],
                                         params[:evaluation_id])
      end
    end
  end
end
