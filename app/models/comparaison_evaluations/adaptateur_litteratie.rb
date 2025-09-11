class ComparaisonEvaluations::AdaptateurLitteratie
  def type
    :litteratie
  end

  def extrait_restitution(restitution_globale)
    restitution_globale.litteratie
  end

  def profil(restitution)
    restitution.niveau_litteratie
  end

  def sous_competences(restitution)
    return {} if restitution.parcours_haut != ::Competence::NIVEAU_INDETERMINE

    restitution.competences_litteratie
  end
end
