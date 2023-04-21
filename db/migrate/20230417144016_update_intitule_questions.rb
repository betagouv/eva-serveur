class UpdateIntituleQuestions < ActiveRecord::Migration[7.0]
  class ::Question < ApplicationRecord; end

  def up
    Question.where(nom_technique: 'vue').update(intitule: 'Avez-vous des problèmes de vue ?')
    Question.where(nom_technique: 'trouble_dys').update(intitule: 'Avez-vous un trouble dys diagnostiqué (dyslexie, dyspraxie, dysphasie, dyscalculie, etc.) ?')
  end

  def down
    Question.where(nom_technique: 'vue').update(intitule: 'Avez-vous un problème de vue ?')
    Question.where(nom_technique: 'trouble_dys').update(intitule: "Êtes-vous suivi·e parce que vous avez des difficultés à lire, écrire, parler, vous repérer dans l'espace ou effectuer certains mouvements, à rester concentré·e ou calme, à mémoriser ou apprendre, ou enfin à calculer ou utiliser des chiffres ?")
  end
end
