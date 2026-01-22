class PasseQuestionsNumeratie2024APassable < ActiveRecord::Migration[7.2]
  def up
    questionnaire = Questionnaire.find_by(nom_technique: 'numeratie_2024')
    return unless questionnaire

    questionnaire.questions.update_all(passable: true)
  end

  def down
    questionnaire = Questionnaire.find_by(nom_technique: 'numeratie_2024')
    return unless questionnaire

    questionnaire.questions.update_all(passable: false)
  end
end
