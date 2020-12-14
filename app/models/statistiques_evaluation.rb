# frozen_string_literal: true

class StatistiquesEvaluation
  attr_reader :debut, :fin, :temps_total

  def initialize(evaluation)
    @evaluation = evaluation
    calcule!
  end

  def calcule!
    return if evenements.blank?

    @debut = evenements.first.date
    @fin = evenements.last.date
    @temps_total = fin - debut
  end

  private

  def evenements
    @evenements ||= Evenement.joins(partie: :evaluation)
                             .where('evaluations.id': @evaluation).order('date ASC')
  end
end
