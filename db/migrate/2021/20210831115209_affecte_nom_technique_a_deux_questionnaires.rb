class AffecteNomTechniqueADeuxQuestionnaires < ActiveRecord::Migration[6.1]
  class Questionnaire < ApplicationRecord; end

  def up
    Questionnaire.find_by(libelle: 'Autopositionnement')
                 &.update(nom_technique: 'autopositionnement')
    Questionnaire.find_by(libelle: 'Livraison')
                 &.update(nom_technique: 'livraison_expression_ecrite')
  end

  def down
    Questionnaire.find_by(libelle: 'Autopositionnement')
                 &.update(nom_technique: '')
    Questionnaire.find_by(libelle: 'Livraison')
                 &.update(nom_technique: '')
  end
end
