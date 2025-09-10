class ComparaisonEvaluations
  def initialize(evaluations)
    @comparateurs = {
      numeratie: Comparateur.new(evaluations, AdaptateurNumeratie.new),
      litteratie: Comparateur.new(evaluations, AdaptateurLitteratie.new)
    }
  end

  def valid?
    @comparateurs[:numeratie].valid? && @comparateurs[:litteratie].valid?
  end

  def tableau_comparaison(type)
    @comparateurs[type].tableau_comparaison
  end

  class Comparateur
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

  class AdaptateurLitteratie
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

  class AdaptateurNumeratie
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
end
