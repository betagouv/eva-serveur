# frozen_string_literal: true

class StatistiquesEvaluation
  attr_reader :debut, :fin, :temps_total

  def initialize(evaluation)
    @evaluation = evaluation
    @debut = @evaluation.created_at
    calcule!
  end

  private

  def calcule!
    durees = Statistiques::Helper.secondes_par_eval('evaluations.id': @evaluation)
    return if durees.empty?

    @temps_total = durees[0]
    @fin = @debut + @temps_total
  end
end
