class CreeQuestionnaireAutopositionnement < ActiveRecord::Migration[7.2]
  def up
    source = Questionnaire.find_by(nom_technique: "sociodemographique_autopositionnement_sante")
    return unless source

    questionnaire = Questionnaire.create!(
      nom_technique: "sociodemographique_autopositionnement",
      libelle: "Sociodémographique et autopositionnement"
    )

    source.questionnaires_questions.order(:position).limit(14).each do |qq|
      questionnaire.questionnaires_questions.create!(
        question_id: qq.question_id,
        position: qq.position
      )
    end
  end

  def down
    questionnaire = Questionnaire.find_by(nom_technique: "sociodemographique_autopositionnement")
    questionnaire&.destroy
  end
end
