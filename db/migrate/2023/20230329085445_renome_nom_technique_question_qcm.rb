class RenomeNomTechniqueQuestionQcm < ActiveRecord::Migration[7.0]
  def up
    QuestionQcm.where(nom_technique: 'niveau_etude').update(nom_technique: 'dernier_niveau_etude')
    QuestionSaisie.where(nom_technique: 'quel_age').update(nom_technique: 'age')
  end
  def down
    QuestionQcm.where(nom_technique: 'dernier_niveau_etude').update(nom_technique: 'niveau_etude')
    QuestionSaisie.where(nom_technique: 'age').update(nom_technique: 'quel_age')
  end
end
