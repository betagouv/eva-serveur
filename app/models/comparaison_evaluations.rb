class ComparaisonEvaluations
  def initialize(evaluations)
    @evaluations = evaluations
  end

  def valid?
    return false if evaluations_numeratie.count > 2
    return false if evaluations_litteratie.count > 2

    true
  end

  def restitutions_numeratie
    @restitutions_numeratie ||= evaluations_numeratie.map do |evaluation|
      FabriqueRestitution.restitution_globale(evaluation)
    end
  end

  def restitutions_litteratie
    @restitutions_litteratie ||= evaluations_litteratie.map do |evaluation|
      FabriqueRestitution.restitution_globale(evaluation)
    end
  end

  def evaluations_numeratie
    @evaluations_numeratie ||= begin
      @evaluations.select do |evaluation|
        evaluation.campagne.avec_positionnement?(:numeratie)
      end.sort_by(&:debutee_le)
    end
  end

  def evaluations_litteratie
    @evaluations_litteratie ||= begin
      @evaluations.select do |evaluation|
        evaluation.campagne.avec_positionnement?(:litteratie)
      end.sort_by(&:debutee_le)
    end
  end

  def tableau_comparaison(type)
    tableau = []
    evaluations = type == :litteratie ? evaluations_litteratie : evaluations_numeratie
    return tableau if evaluations.blank?

    2.times do |numero_evaluation|
      evaluation = evaluations[numero_evaluation]

      profil, sous_competences = if type == :litteratie
        [ profil_litteratie(numero_evaluation), sous_competences_litteratie(numero_evaluation) ]
      else
        [ profil_numeratie(numero_evaluation), sous_competences_numeratie(numero_evaluation) ]
      end

      tableau << {
        evaluation: evaluation,
        profil: evaluation ? profil : nil,
        sous_competences: evaluation ? sous_competences : nil
      }
    end

    tableau
  end

  private

  def restitution_litteratie(numero_evaluation)
    restitutions_litteratie[numero_evaluation].litteratie
  end

  def profil_litteratie(numero_evaluation)
    restitution = restitution_litteratie(numero_evaluation)
    restitution ? restitution.niveau_litteratie : "indetermine"
  end

  def sous_competences_litteratie(numero_evaluation)
    restitution = restitution_litteratie(numero_evaluation)
    return {} if restitution.nil?
    return {} if restitution.parcours_haut != ::Competence::NIVEAU_INDETERMINE

    restitution.competences_litteratie
  end

  def restitution_numeratie(numero_evaluation)
    restitutions_numeratie[numero_evaluation].numeratie
  end

  def profil_numeratie(numero_evaluation)
    restitution = restitution_numeratie(numero_evaluation)
    restitution ? restitution.profil_numeratie : "indetermine"
  end

  def sous_competences_numeratie(numero_evaluation)
    restitution = restitution_numeratie(numero_evaluation)
    restitution ? restitution.competences_numeratie : {}
  end
end
