class ComparaisonEvaluations::Comparateur
  MAX_EVALUATION_PAR_TYPE = 2

  def initialize(restitutions_globales, adaptateur_type)
    @adaptateur_type = adaptateur_type

    @restitutions_globales = restitutions_globales.select do |restitution|
      restitution.evaluation.campagne.avec_positionnement?(@adaptateur_type.type)
    end
  end

  def valid?
    @restitutions_globales.count <= MAX_EVALUATION_PAR_TYPE
  end

  def tableau_comparaison
    return [] if @restitutions_globales.blank?

    MAX_EVALUATION_PAR_TYPE.times.map do |numero_evaluation|
      restitution_globale = @restitutions_globales[numero_evaluation]

      construit_ligne_tableau(restitution_globale)
    end
  end

  def construit_ligne_tableau(restitution_globale)
    return { evaluation: nil } if restitution_globale.blank?

    evaluation = restitution_globale.evaluation

    restitution = @adaptateur_type.extrait_restitution(restitution_globale)
    profil = restitution ? @adaptateur_type.profil(restitution) : ::Competence::NIVEAU_INDETERMINE
    sous_competences = restitution ? @adaptateur_type.sous_competences(restitution) : {}

    {
      evaluation: evaluation,
      profil: profil,
      sous_competences: sous_competences
    }
  end
end
