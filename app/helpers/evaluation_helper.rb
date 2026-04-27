module EvaluationHelper
  def niveau_bas?(profil)
    ::Competence::PROFILS_BAS.include?(profil)
  end

  def affiche_colonne_structure?(compte = current_compte)
    compte.anlci? || compte.administratif?
  end

  def classes_colonne_campagne(affiche_structure)
    classes = [ "evaluation__col-campagne" ]
    classes << "evaluation__col-campagne--sans-structure" unless affiche_structure
    classes.join(" ")
  end

  def affiche_sous_titre_campagne?(parcours_type, compte = current_compte)
    parcours_type.present? && !compte.administratif?
  end

  def presence_pastille?
    liste_filtree_illettrisme_potentiel = params[:scope] == "illettrisme_potentiel"
    liste_filtree_illettrisme_potentiel ? false : true
  end
end
