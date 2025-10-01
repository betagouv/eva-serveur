class StatistiquesEvaluation
  attr_reader :temps_total

  def initialize(evaluation)
    @evaluation = evaluation
    @temps_total = calcule_temps_total
  end

  private

  def calcule_temps_total
    return @evaluation.terminee_le - @evaluation.debutee_le if @evaluation.terminee_le.present?

    durees = Statistiques::Helper.secondes_par_eval('evaluations.id': @evaluation)
    durees[0].to_f unless durees.empty?
  end
end
