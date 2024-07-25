# frozen_string_literal: true

module Admin
  module Positionnement
    class ReponsesController < Api::BaseController
      def show
        partie_numeratie = find_partie(params[:partie_numeratie_id])
        partie_litteratie = find_partie(params[:partie_litteratie_id])

        redirect_to root_path unless abilities?(partie_numeratie, partie_litteratie)

        export = ::Restitution::ExportPositionnement.new(partie_numeratie: partie_numeratie,
                                                         partie_litteratie: partie_litteratie)
        send_data export.to_xls,
                  content_type: 'application/vnd.ms-excel',
                  filename: nom_du_fichier(partie_numeratie)
      end

      def nom_du_fichier(partie)
        code_de_campagne = partie.evaluation.campagne.code.parameterize
        nom_de_levaluation = partie.evaluation.nom.parameterize.first(15)
        date = DateTime.current.strftime('%Y%m%d')
        "#{date}-#{nom_de_levaluation}-#{code_de_campagne}.xls"
      end

      private

      def find_partie(partie_id)
        return nil if partie_id.blank?

        Partie.find_by(id: partie_id)
      end

      def abilities?(partie_numeratie, partie_litteratie)
        Ability.new(current_compte).can?(:read, partie_numeratie&.evaluation) &&
          Ability.new(current_compte).can?(:read, partie_litteratie&.evaluation)
      end
    end
  end
end
