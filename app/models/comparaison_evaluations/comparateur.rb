class ComparaisonEvaluations::Comparateur
  MAX_EVALUATION_PAR_TYPE = 2

  def initialize(evaluations_restitutions, adaptateur_type)
    @adaptateur_type = adaptateur_type

    @evaluations_restitutions = evaluations_restitutions.select do |evaluation_restitution|
      evaluation_restitution[0].campagne.avec_positionnement?(@adaptateur_type.type)
    end.sort { |er| er[0].debutee_le }
  end

  def valid?
    @evaluations_restitutions.count <= MAX_EVALUATION_PAR_TYPE
  end

  def tableau_comparaison
    return [] if @evaluations_restitutions.blank?

    MAX_EVALUATION_PAR_TYPE.times.map do |numero_evaluation|
      evaluation_restitution = @evaluations_restitutions[numero_evaluation]

      construit_ligne_tableau(evaluation_restitution)
    end
  end

  def construit_ligne_tableau(evaluation_restitution)
    return { evaluation: nil } if evaluation_restitution.blank?

    evaluation = evaluation_restitution[0]

    restitution = @adaptateur_type.extrait_restitution(evaluation_restitution[1])
    profil = restitution ? @adaptateur_type.profil(restitution) : ::Competence::NIVEAU_INDETERMINE
    sous_competences = restitution ? @adaptateur_type.sous_competences(restitution) : {}

    {
      evaluation: evaluation,
      profil: profil,
      sous_competences: sous_competences
    }
  end
end
