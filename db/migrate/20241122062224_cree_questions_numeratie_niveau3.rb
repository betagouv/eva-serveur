class CreeQuestionsNumeratieNiveau3 < ActiveRecord::Migration[7.0]
  class ::Question < ApplicationRecord; end
  class ::Questionnaire < ApplicationRecord; end
  class ::QuestionnaireQuestion < ApplicationRecord; end

  def up
    numeratie = Questionnaire.find_or_create_by(nom_technique: 'numeratie_2024')
    {
      QuestionClicDansImage::QUESTION_TYPE => ['N3Pim2', 'N3Pim4', 'N3Rpr1', 'N3Pim1', 'N3Pim3'],
      QuestionQcm::QUESTION_TYPE => ['N3Ppl1', 'N3Rpl1', 'N3Ppo1', 'N3Rpo1', 'N3Rvo2', 'N3Rrp2'],
      QuestionSaisie::QUESTION_TYPE => ['N3Ppl2', 'N3Rpl2', 'N3Put1', 'N3Put2', 'N3Rut1', 'N3Rut2', 'N3Pum2', 'N3Pum4', 'N3Ppo2', 'N3Rpo2', 'N3Ppr1', 'N3Ppr2', 'N3Rpr2', 'N3Pps1', 'N3Pps2', 'N3Rps1', 'N3Rps2', 'N3Pvo1', 'N3Pvo2', 'N3Rvo1', 'N3Prp1', 'N3Prp2', 'N3Rrp1'],
      QuestionGlisserDeposer::QUESTION_TYPE => ['N3Pum1', 'N3Pum3']
    }.each do |type, nom_techniques|
      nom_techniques.each do |nom_technique|
        question = Question.find_or_initialize_by(nom_technique: nom_technique)
        question.type = type
        question.type_saisie = :numerique if type == QuestionSaisie::QUESTION_TYPE
        question.libelle = nom_technique
        question.save!
        QuestionnaireQuestion.find_or_create_by(questionnaire_id: numeratie.id, question_id: question.id)
      end
    end
  end
end
