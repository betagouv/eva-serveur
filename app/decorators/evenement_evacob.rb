class EvenementEvacob < SimpleDelegator
  PREFIX_QUESTIONS = {
    orientation: "LO",
    hpar: "HPar",
    hgac: "HGac",
    hcvf: "HCvf",
    hpfb: "HPfb"
  }.freeze

  def bonne_reponse?
    donnees["succes"]
  end

  def module?(nom_module)
    donnees["question"].start_with?(PREFIX_QUESTIONS[nom_module])
  end

  def metacompetence?(metacompetence)
    donnees["metacompetence"] == metacompetence
  end

  def score_reponse
    donnees["score"] || 0
  end
end
