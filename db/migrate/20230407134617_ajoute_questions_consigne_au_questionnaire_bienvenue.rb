class AjouteQuestionsConsigneAuQuestionnaireBienvenue < ActiveRecord::Migration[7.0]
  class Questionnaire < ApplicationRecord; end
  class ::Question < ApplicationRecord; end
  class ::QuestionSousConsigne < Question; end

  def up
    change_column :questions, :intitule, :text
    questionnaire = Questionnaire.find_by(nom_technique: 'sociodemographique_autopositionnement')
    question_auto = QuestionSousConsigne.find_or_create_by(libelle: 'Sous consigne - Autopositionnement',
      nom_technique: 'sous_consigne_autopositionnement',
      intitule: %{Maintenant, nous allons vous demander de nous dire à quel point chaque phrase vous correspond.

Vous devez répondre en utilisant une échelle allant de 1 « pas du tout », à 7 « tout à fait ».  
Par exemple, à la phrase « j'adore les séries télévisées », sélectionnez le chiffre 7 si vous adorez les séries télévisées.})
    QuestionnaireQuestion.find_or_create_by(questionnaire_id: questionnaire.id, question_id: question_auto.id, position: 7)
    question_sante = QuestionSousConsigne.find_or_create_by(libelle: 'Sous consigne - Santé',
      nom_technique: 'sous_consigne_sante',
      intitule: "Maintenant, merci de répondre à ces quelques questions, qui nous permettront de mieux interpréter vos résultats sur eva.")
    QuestionnaireQuestion.find_or_create_by(questionnaire_id: questionnaire.id, question_id: question_sante.id, position: 15)
  end

  def down
    change_column :questions, :intitule, :string
    question = QuestionSousConsigne.find_by(nom_technique: "sous_consigne_autopositionnement")
    QuestionnaireQuestion.find_by(question_id: question.id).really_destroy!
    question.really_destroy!
    question = QuestionSousConsigne.find_by(nom_technique: "sous_consigne_sante")
    QuestionnaireQuestion.find_by(question_id: question.id).really_destroy!
    question.really_destroy!
  end
end
