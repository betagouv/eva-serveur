# frozen_string_literal: true

module ComparaisonEvaluationsHelper
  def tableau_comparaison_litteratie(comparaison)
    tableau = []
    evaluations = comparaison.evaluations_litteratie
    return tableau if evaluations.blank?

    2.times do |numero_evaluation|
      evaluation = evaluations[numero_evaluation]
      profil = evaluation ? profil_litteratie(comparaison, numero_evaluation) : nil
      sous_competences = evaluation ? sous_competences_litteratie(comparaison, numero_evaluation) : nil
      tableau << {
        evaluation: evaluation,
        profil: profil,
        sous_competences: sous_competences
      }
    end
    tableau
  end

  def tableau_comparaison_numeratie(comparaison)
    tableau = []
    evaluations = comparaison.evaluations_numeratie
    return tableau if evaluations.blank?

    2.times do |numero_evaluation|
      evaluation = evaluations[numero_evaluation]
      profil = evaluation ? profil_numeratie(comparaison, numero_evaluation) : nil
      sous_competences = evaluation ? sous_competences_numeratie(comparaison, numero_evaluation) : nil
      tableau << {
        evaluation: evaluation,
        profil: profil,
        sous_competences: sous_competences
      }
    end
    tableau
  end

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
