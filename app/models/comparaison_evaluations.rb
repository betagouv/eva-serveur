class ComparaisonEvaluations
  def initialize(evaluations)
    evaluations_restitutions = evaluations.map do |evaluation|
      [evaluation, FabriqueRestitution.restitution_globale(evaluation)]
    end
    @comparateurs = {
      numeratie: Comparateur.new(evaluations_restitutions, AdaptateurNumeratie.new),
      litteratie: Comparateur.new(evaluations_restitutions, AdaptateurLitteratie.new)
    }
  end

  def valid?
    @comparateurs[:numeratie].valid? && @comparateurs[:litteratie].valid?
  end

  def tableau_comparaison(type)
    @comparateurs[type].tableau_comparaison
  end
end
