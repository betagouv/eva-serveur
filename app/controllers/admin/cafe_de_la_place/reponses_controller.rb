# frozen_string_literal: true

module Admin
  module CafeDeLaPlace
    class ReponsesController < Api::BaseController
      def show
        partie_id = params[:partie_id]
        partie = Partie.find(partie_id)
        redirect_to root_path unless Ability.new(current_compte).can?(:read, partie.evaluation)
        export_cafe_de_la_place = ::Restitution::ExportCafeDeLaPlace.new(partie: partie)
        send_data export_cafe_de_la_place.to_xls,
                  content_type: 'application/vnd.ms-excel',
                  filename: "#{partie_id}-#{DateTime.current.strftime('%Y%m%d')}.xls"
      end
    end
  end
end
