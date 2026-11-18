module QuestionHelper
  def type_clic(question)
    question.clic_multiple? ? "multiple" : "simple"
  end

  def bouton_export_question_xls(question)
    render BoutonDsfrComponent.new(
      export_xls_admin_question_path(question),
      tag: :telechargement,
      type: :secondary,
      size: :sm
    ).with_content(t("admin.questions.action_items.exporter_question"))
  end
end
