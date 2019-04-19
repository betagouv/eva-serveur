# frozen_string_literal: true

class EvaluationBase
  delegate :session_id, :utilisateur, :situation, :date, to: :premier_evenement

  def initialize(evenements)
    @evenements = evenements
  end

  def compte_nom_evenements(nom)
    @evenements.count { |e| e.nom == nom }
  end

  def temps_total
    @evenements.last.date - @evenements.first.date
  end

  def premier_evenement
    @evenements.first
  end
end
