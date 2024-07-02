# frozen_string_literal: true

class EvenementPlaceDuMarche < SimpleDelegator
  PREFIX_QUESTIONS = {
    N1P: 'N1P',
    NumeratieN2: 'NumeratieN2',
    NumeratieN3: 'NumeratieN3'
  }.freeze

  def module?(nom_module)
    donnees['question'].start_with?(PREFIX_QUESTIONS[nom_module])
  end

  def score_reponse
    donnees['score'] || 0
  end
end
