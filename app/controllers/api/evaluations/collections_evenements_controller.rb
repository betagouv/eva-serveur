# frozen_string_literal: true

module Api
  module Evaluations
    class CollectionsEvenementsController < Api::BaseController
      def create
        @evenements = cree_evenements

        if @evenements.all?(&:persisted?)
          render json: {}, status: :created
        else
          render json: {}, status: :unprocessable_entity
        end
      end

      private

      def cree_evenements
        evenements = []
        params[:evenements].each do |parametres|
          parametres.merge!(evaluation_id: params[:evaluation_id])
          evenements << FabriqueEvenement.new(parametres).call
        end
        evenements
      end
    end
  end
end
