class CreeQuestionnaireSante < ActiveRecord::Migration[7.2]
  def up
    source = Questionnaire.find_by(nom_technique: "sociodemographique_autopositionnement_sante")
    return unless source

    questionnaire = Questionnaire.create!(
      nom_technique: "sociodemographique_sante",
      libelle: "Sociodémographique et santé"
    )

    questions_source = source.questionnaires_questions.order(:position)
    premieres = questions_source.limit(6)
    dernieres = questions_source.last(5)

    position = 1
    (premieres + dernieres).each do |qq|
      questionnaire.questionnaires_questions.create!(
        question_id: qq.question_id,
        position: position
      )
      position += 1
    end
  end

  def down
    questionnaire = Questionnaire.find_by(nom_technique: "sociodemographique_sante")
    questionnaire&.destroy
  end
end
