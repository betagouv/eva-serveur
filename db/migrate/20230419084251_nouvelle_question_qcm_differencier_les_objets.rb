class NouvelleQuestionQcmDifferencierLesObjets < ActiveRecord::Migration[7.0]
  class ::Questionnaire < ApplicationRecord; end
  class ::Question < ApplicationRecord; end
  class ::QuestionQcm < Question; end

  def up
    old_question = Question.find_by(nom_technique: 'differencier_objets')
    old_question.update(nom_technique: 'confondre_objets')
    new_question = QuestionQcm.find_or_create_by(nom_technique: 'differencier_objets', type_qcm: 'jauge') do |question|
      question.libelle = 'Il est facile pour moi de différencier les objets.'
      question.choix = [
        Choix.new(nom_technique: 'pas_du_tout_daccord', intitule: "1 : Pas du tout d'accord", type_choix: 'bon'),
        Choix.new(nom_technique: 'pas_daccord', intitule: "2 : Pas d'accord", type_choix: 'bon'),
        Choix.new(nom_technique: 'plutot_pas_daccord', intitule: "3 : Plutôt pas d'accord", type_choix: 'bon'),
        Choix.new(nom_technique: 'ni_daccord_ni_pas_daccord', intitule: "4 : Ni d'accord, ni pas d'accord", type_choix: 'bon'),
        Choix.new(nom_technique: 'plutot_daccord', intitule: "5 : Plutôt d'accord", type_choix: 'bon'),
        Choix.new(nom_technique: 'daccord', intitule: "6 : D'accord", type_choix: 'bon'),
        Choix.new(nom_technique: 'tout_a_fait_daccord', intitule: "7 : Tout à fait d'accord", type_choix: 'bon')
      ]
      question.intitule = "Il est facile pour moi de différencier les objets, même lorsqu'ils ont des formes ou des couleurs qui se ressemblent."
    end
    QuestionnaireQuestion.where(question_id: old_question.id).update_all(question_id: new_question.id)
  end
end
