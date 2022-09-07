module Api
  module Admin
    class ReponsesController < Api::BaseController
      def show
        evaluation_id = params[:evaluation_id]
        evaluation = Evaluation.find(evaluation_id)
        reponse_service = ::Evaluations::ReponseService.new(evaluation: evaluation,
                                                            nom_technique: Restitution::CafeDeLaPlace::NOM_TECHNIQUE)
        send_data reponse_service.to_xls,
                  content_type: 'application/vnd.ms-excel',
                  filename: "#{evaluation_id}-#{DateTime.current.strftime('%Y%m%d')}.xls" and return
      end
    end
  end
end
