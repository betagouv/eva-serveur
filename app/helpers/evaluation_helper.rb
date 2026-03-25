module EvaluationHelper
  def niveau_bas?(profil)
    ::Competence::PROFILS_BAS.include?(profil)
  end

  def presence_pastille?
    liste_filtree_illettrisme_potentiel = params[:scope] == "illettrisme_potentiel"
    liste_filtree_illettrisme_potentiel ? false : true
  end

  def diag_risques_entreprise
    restitution_pour_situation(Situation::DIAG_RISQUES_ENTREPRISE)
  end

  def cafe_de_la_place
    restitution_pour_situation(Situation::CAFE_DE_LA_PLACE)
  end

  def place_du_marche
    restitution_pour_situation(Situation::PLACE_DU_MARCHE)
  end
end
