ActiveAdmin.register Question do
  menu false

  member_action :export_xls, method: :get do
    question = Question.find(params[:id])
    export =
      ImportExport::Questions::ImportExportDonnees.new(questions: [ question ], type: question.type)
                                                  .exporte_donnees
    send_data export[:xls],
              content_type: export[:content_type],
              filename: export[:filename]
  end
end
