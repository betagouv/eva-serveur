class RenommeNomTechniquesQuestionsBienvenue < ActiveRecord::Migration[7.0]
  def up
    QuestionQcm.where(nom_technique: 'bienvenue_1').update(nom_technique: 'concentration')
    QuestionQcm.where(nom_technique: 'bienvenue_2').update(nom_technique: 'comprehension')
    QuestionQcm.where(nom_technique: 'bienvenue_3').update(nom_technique: 'differencier_objets')
    QuestionQcm.where(nom_technique: 'bienvenue_4').update(nom_technique: 'analyse_travail')
    QuestionQcm.where(nom_technique: 'bienvenue_5').update(nom_technique: 'tache_longue_et_difficile')
    QuestionQcm.where(nom_technique: 'bienvenue_6').update(nom_technique: 'travail_sans_erreur')
    QuestionQcm.where(nom_technique: 'bienvenue_7').update(nom_technique: 'dangers')
    QuestionQcm.where(nom_technique: 'bienvenue_8').update(nom_technique: 'vue')
    QuestionQcm.where(nom_technique: 'bienvenue_10').update(nom_technique: 'entendre')
    QuestionQcm.where(nom_technique: 'bienvenue_15').update(nom_technique: 'trouble_dys')
  end

  def down
    QuestionQcm.where(nom_technique: 'concentration').update(nom_technique: 'bienvenue_1')
    QuestionQcm.where(nom_technique: 'comprehension').update(nom_technique: 'bienvenue_2')
    QuestionQcm.where(nom_technique: 'differencier_objets').update(nom_technique: 'bienvenue_3')
    QuestionQcm.where(nom_technique: 'analyse_travail').update(nom_technique: 'bienvenue_4')
    QuestionQcm.where(nom_technique: 'tache_longue_et_difficile').update(nom_technique: 'bienvenue_5')
    QuestionQcm.where(nom_technique: 'travail_sans_erreur').update(nom_technique: 'bienvenue_6')
    QuestionQcm.where(nom_technique: 'dangers').update(nom_technique: 'bienvenue_7')
    QuestionQcm.where(nom_technique: 'vue').update(nom_technique: 'bienvenue_8')
    QuestionQcm.where(nom_technique: 'entendre').update(nom_technique: 'bienvenue_10')
    QuestionQcm.where(nom_technique: 'trouble_dys').update(nom_technique: 'bienvenue_15')
  end
end
