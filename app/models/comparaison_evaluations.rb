class ComparaisonEvaluations
  def initialize(evaluations)
    restitutions_globales = evaluations.sort_by(&:debutee_le).map do |evaluation|
      FabriqueRestitution.restitution_globale(evaluation)
    end
    @comparateurs = {
      numeratie: Comparateur.new(restitutions_globales, AdaptateurNumeratie.new),
      litteratie: Comparateur.new(restitutions_globales, AdaptateurLitteratie.new)
    }
  end

  def valid?
    @comparateurs[:numeratie].valid? && @comparateurs[:litteratie].valid?
  end

  def tableau_comparaison(type)
    @comparateurs[type].tableau_comparaison
  end
end
