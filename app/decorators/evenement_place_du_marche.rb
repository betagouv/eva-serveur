class EvenementPlaceDuMarche < SimpleDelegator
  PREFIX_QUESTIONS = {
    N1: "N1",
    N2: "N2",
    N3: "N3"
  }.freeze

  def module?(nom_module)
    donnees["question"].start_with?(PREFIX_QUESTIONS[nom_module])
  end

  def score_reponse
    donnees["score"] || 0
  end

  def score_max_reponse
    donnees["scoreMax"] || 0
  end
end
