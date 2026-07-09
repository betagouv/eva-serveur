class EvaluationEva < Evaluation
  def self.model_name
    # Temporairement, en attendant la séparation des modeles,
    # pour réparer le formulaire de modification
    Evaluation.model_name
  end
end
