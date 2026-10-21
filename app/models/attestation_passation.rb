class AttestationPassation
  def initialize(evaluation)
    @evaluation = evaluation
  end

  def disponible?
    @evaluation.complete?
  end
end
