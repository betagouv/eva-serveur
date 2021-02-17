# frozen_string_literal: true

class StatistiquesEvaluation
  attr_reader :temps_total

  def initialize(evaluation)
    @evaluation = evaluation
    calcule!
  end

  private

  def calcule!
    durees = Statistiques::Helper.secondes_par_eval('evaluations.id': @evaluation)
    return if durees.empty?

    @temps_total = durees[0]
  end
end
