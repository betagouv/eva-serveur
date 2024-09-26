class CreationQuestionsNumeratieNiveau2 < ActiveRecord::Migration[7.0]
  class ::Question < ApplicationRecord; end
  class ::Questionnaire < ApplicationRecord; end
  class ::QuestionnaireQuestion < ApplicationRecord; end

  def change
    numeratie = Questionnaire.find_or_create_by(nom_technique: 'numeratie_2024')
    {
      'QuestionClicDansImage' => ['N2Plp1', 'N2Pod1', 'N2Pod2'],
      'QuestionQcm' => ['N2Plp2', 'N2Rlp1', 'N2Rlp2', 'N2Put1', 'N2Put2', 'N2Rut1', 'N2Rut2', 'N2Ptg2', 'N2Rtg1', 'N2Rtg2', 'N2Ppl1', 'N2Rpl1', 'N2Rpl2'],
      'QuestionSaisie' => ['N2Ppe1', 'N2Ppe2', 'N2Rpe1', 'N2Rpe2', 'N2Psu1', 'N2Psu2', 'N2Rsu1', 'N2Rsu2', 'N2Pom1', 'N2Pom2', 'N2Rom1', 'N2Rom2', 'N2Rod1', 'N2Rod2', 'N2Ptg1', 'N2Ppl2'],
      'QuestionGlisserDeposer' => ['N2Pon1', 'N2Pon2', 'N2Ron1', 'N2Ron2']
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
