# frozen_string_literal: true

module ComparaisonEvaluationsHelper
  def restitution_litteratie(comparaison, numero_evaluation)
    comparaison.restitutions_litteratie[numero_evaluation].litteratie
  end

  def profil_litteratie(comparaison, numero_evaluation)
    restitution_litteratie = restitution_litteratie(comparaison, numero_evaluation)
    restitution_litteratie ? restitution_litteratie.niveau_litteratie : "indetermine"
  end

  def sous_competences_litteratie(comparaison, numero_evaluation)
    restitution_litteratie = restitution_litteratie(comparaison, numero_evaluation)
    return {} if restitution_litteratie.nil?
    return {} if restitution_litteratie.parcours_haut != ::Competence::NIVEAU_INDETERMINE

    restitution_litteratie.competences_litteratie
  end

  def restitution_numeratie(comparaison, numero_evaluation)
    comparaison.restitutions_numeratie[numero_evaluation].numeratie
  end

  def profil_numeratie(comparaison, numero_evaluation)
    restitution_numeratie = restitution_numeratie(comparaison, numero_evaluation)
    restitution_numeratie ? restitution_numeratie.profil_numeratie : "indetermine"
  end

  def sous_competences_numeratie(comparaison, numero_evaluation)
    restitution_numeratie = restitution_numeratie(comparaison, numero_evaluation)
    restitution_numeratie ? restitution_numeratie.competences_numeratie : {}
  end
end
