module Api
  module Evaluations
    class CollectionsEvenementsController < Api::BaseController
      def create
        if Evaluation.where(id: permit_params[:evaluation_id]).exists?
          persiste_evenements
          render json: {}, status: :created
        else
          render json: { message: I18n.t("admin.evaluations.inconnue") },
                 status: :unprocessable_content
        end
      end

      private

      def persiste_evenements
        arguments = [ permit_params[:evaluation_id], permit_params[:evenements] ]
        if synchrone?
          PersisteCollectionEvenementsJob.perform_now(*arguments)
        else
          PersisteCollectionEvenementsJob.perform_later(*arguments)
        end
      end

      def synchrone?
        ActiveModel::Type::Boolean.new.cast(params[:synchrone])
      end

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
