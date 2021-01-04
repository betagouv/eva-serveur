# frozen_string_literal: true

class StatistiquesEvaluation
  attr_reader :debut, :fin, :temps_total

  def initialize(evaluation)
    @evaluation = evaluation
    calcule!
  end

  private

  def calcule!
    @debut = @evaluation.created_at
    return if dernier_evenement.blank?

    @fin = dernier_evenement.date
    @temps_total = @fin - @debut
  end

  def dernier_evenement
    @dernier_evenement ||= Evenement.joins(partie: :evaluation)
                                    .where('evaluations.id': @evaluation).order('date ASC')
                                    .last
  end
end
