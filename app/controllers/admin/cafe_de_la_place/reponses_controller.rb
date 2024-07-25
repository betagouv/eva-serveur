# frozen_string_literal: true

module Admin
  module CafeDeLaPlace
    class ReponsesController < Api::BaseController
      def show
        partie = Partie.find(params[:partie_id])
        redirect_to root_path unless Ability.new(current_compte).can?(:read, partie.evaluation)
        export = ::Restitution::ExportPositionnement.new(partie: partie)
        send_data export.to_xls,
                  content_type: 'application/vnd.ms-excel',
                  filename: nom_du_fichier(partie)
      end

      def nom_du_fichier(partie)
        code_de_campagne = partie.evaluation.campagne.code.parameterize
        nom_de_levaluation = partie.evaluation.nom.parameterize.first(15)
        date = DateTime.current.strftime('%Y%m%d')
        "#{date}-#{nom_de_levaluation}-#{code_de_campagne}.xls"
      end
    end
  end
end
