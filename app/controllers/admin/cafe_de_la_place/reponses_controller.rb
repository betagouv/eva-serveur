# frozen_string_literal: true

module Admin
  module CafeDeLaPlace
    class ReponsesController < Api::BaseController
      def show
        partie = Partie.find(params[:partie_id])
        redirect_to root_path unless Ability.new(current_compte).can?(:read, partie.evaluation)
        export = ::Restitution::ExportCafeDeLaPlace.new(partie: partie)
        send_data export.to_xls,
                  content_type: 'application/vnd.ms-excel',
                  filename: nom_du_fichier(partie)
      end

      private

      def nom_du_fichier(partie)
<<<<<<< HEAD
        campagne_code = partie.evaluation.campagne.code.parameterize
        nom_de_partie = partie.evaluation.nom.parameterize
        date = DateTime.current.strftime('%Y%m%d')
        "#{date}-#{nom_de_partie}-#{campagne_code}.xls"
=======
        code_de_campagne = partie.evaluation.campagne.code.parameterize
        nom_de_partie = partie.evaluation.nom.parameterize.first(15)
        date = DateTime.current.strftime('%Y%m%d')
        "#{date}-#{nom_de_partie}-#{code_de_campagne}.xls"
>>>>>>> db9184f7 (enlever le .evenements)
      end
    end
  end
end
