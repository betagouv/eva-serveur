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
end
