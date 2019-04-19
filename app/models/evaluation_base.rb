# frozen_string_literal: true

class EvaluationBase
  def initialize(evenements)
    @evenements = evenements
  end

  def compte_nom_evenements(nom)
    @evenements.count { |e| e.nom == nom }
  end

  def session_id
    @evenements.first.session_id
  end
end
