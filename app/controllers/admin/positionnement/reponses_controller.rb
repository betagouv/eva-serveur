module Admin
  module Positionnement
    class ReponsesController < ApplicationController
      before_action :find_partie

      def show
        redirect_to(root_path) and return unless can_read_partie?

        export = ::Restitution::Positionnement::Export.new(partie: @partie)
        send_data export.to_xls,
                  content_type: export.content_type_xls,
                  filename: export.nom_du_fichier
      end

      private

      def find_partie
        @partie = Partie.find(params[:partie_id])
        @evaluation = @partie.evaluation
      end

      def can_read_partie?
        return false if current_compte.nil?

        current_ability.can?(:read, @evaluation)
      end
    end
  end
end
