class AttestationPassation
  def self.active?
    ENV["ACTIVE_ATTESTATION_PASSATION_EVAPRO"].present?
  end

  def initialize(evaluation)
    @evaluation = evaluation
  end

  def disponible?
    self.class.active? && @evaluation.complete?
  end
end
