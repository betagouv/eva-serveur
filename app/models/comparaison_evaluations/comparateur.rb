class ComparaisonEvaluations::Comparateur
  MAX_EVALUATION_PAR_TYPE = 2

  def initialize(evaluations, adaptateur_type)
    @adaptateur_type = adaptateur_type

    @evaluations = evaluations.select do |evaluation|
      evaluation.campagne.avec_positionnement?(@adaptateur_type.type)
    end.sort_by(&:debutee_le)
  end

  def valid?
    @evaluations.count <= MAX_EVALUATION_PAR_TYPE
  end

  def restitutions
    @evaluations.map do |evaluation|
      restitution_globale = FabriqueRestitution.restitution_globale(evaluation)
      @adaptateur_type.extrait_restitution(restitution_globale)
    end
  end

  def tableau_comparaison
    tableau = []
    return tableau if @evaluations.blank?

    MAX_EVALUATION_PAR_TYPE.times do |numero_evaluation|
      evaluation = @evaluations[numero_evaluation]

      tableau << construit_ligne_tableau(evaluation, numero_evaluation)
    end

    tableau
  end

  def construit_ligne_tableau(evaluation, numero_evaluation)
    return { evaluation: evaluation } if restitutions[numero_evaluation].blank?

    restitution = restitutions[numero_evaluation]
    profil = restitution ? @adaptateur_type.profil(restitution) : ::Competence::NIVEAU_INDETERMINE
    sous_competences = restitution ? @adaptateur_type.sous_competences(restitution) : {}

    {
      evaluation: evaluation,
      profil: profil,
      sous_competences: sous_competences
    }
  end
end
