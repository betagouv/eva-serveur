class ComparaisonEvaluations::AdaptateurNumeratie
  def type
    :numeratie
  end

  def extrait_restitution(restitution_globale)
    restitution_globale.numeratie
  end

  def profil(restitution)
    restitution.profil_numeratie
  end

  def sous_competences(restitution)
    restitution.competences_numeratie
  end
end
