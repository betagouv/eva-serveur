class ComparaisonEvaluations
  def initialize(evaluations)
    @evaluations = evaluations
  end

  ##
  # Ne doit pas avoir plus de 2 évaluations pour la compétence Numératie
  # et plus de 2 évaluations pour la compétence Littératie
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

  ##
  # Les évaluations pour la numératie, trier du plus vieux au plus récent
  def evaluations_numeratie
    @evaluations_numeratie ||= begin
      @evaluations.select do |evaluation|
        evaluation.campagne.avec_positionnement?(:numeratie)
      end.sort_by(&:debutee_le)
    end
  end

  ##
  # Les évaluations pour la littératie, trier du plus vieux au plus récent
  def evaluations_litteratie
    @evaluations_litteratie ||= begin
      @evaluations.select do |evaluation|
        evaluation.campagne.avec_positionnement?(:litteratie)
      end.sort_by(&:debutee_le)
    end
  end
end
