module Api
  module Evaluations
    class CollectionsEvenementsController < Api::BaseController
      def create
        if Evaluation.exists?(permit_params[:evaluation_id])
          PersisteCollectionEvenementsJob.perform_later(
            permit_params[:evaluation_id],
            permit_params[:evenements]
          )
          render json: {}, status: :created
        else
          render json: { message: I18n.t("admin.evaluations.inconnue") },
                 status: :unprocessable_content
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
    end
  end
end
