class CreationQuestionNumeratie < ActiveRecord::Migration[7.0]
  class ::Question < ApplicationRecord; end
  class ::Questionnaire < ApplicationRecord; end
  class ::QuestionnaireQuestion < ApplicationRecord; end

  def change
    numeratie = Questionnaire.find_or_create_by(nom_technique: 'numeratie_2024') do |q|
      q.libelle = 'Numératie 2024'
    end
    {
      'QuestionClicDansImage' => ['N1Pse1', 'N1Pse2', 'N1Pse3', 'N1Pse4'],
      'QuestionQcm' => ['N1Prn1', 'N1Prn2', 'N1Rrn1', 'N1Rrn2', 'N1Pes1', 'N1Pes2', 'N1Res1', 'N1Res2', 'N1Pon2', 'N1Pvn1', 'N1Pvn2', 'N1Pvn3', 'N1Pvn4'],
      'QuestionSaisie' => ['N1Pde1', 'N1Pde2', 'N1Rde1', 'N1Rde2', 'N1Poa1', 'N1Poa2', 'N1Roa1', 'N1Roa2', 'N1Pos1', 'N1Pos2', 'N1Ros1', 'N1Ros2'],
      'QuestionGlisserDeposer' => ['N1Pon1', 'N1Ron1', 'N1Ron2']
    }.each do |type, nom_techniques|
      nom_techniques.each do |nom_technique|
        question = Question.find_or_initialize_by(nom_technique: nom_technique)
        question.type = type
        question.type_saisie = :numerique if type == 'QuestionSaisie'
        question.libelle = nom_technique
        question.save!
        QuestionnaireQuestion.find_or_create_by(questionnaire_id: numeratie.id, question_id: question.id)
      end
    end
  end
end
