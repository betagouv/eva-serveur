module ExportQuestionsXls
  extend ActiveSupport::Concern

  included do
    before_action :exporte_questions_xls, only: :index, if: -> { request.format.xls? }
  end

  private

  def exporte_questions_xls
    export =
      ImportExport::Questions::ImportExportDonnees.new(
        questions: find_collection(except: :pagination),
        type: resource_class::QUESTION_TYPE
      ).exporte_donnees
    send_data export[:xls],
              content_type: export[:content_type],
              filename: export[:filename]
  end
end
