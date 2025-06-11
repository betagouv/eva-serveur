class LieurEvaluations
  attr_reader :evaluations

  def initialize(evaluations)
    @evaluations = evaluations
  end

  def call
    beneficiaire = beneficiaire_le_plus_ancien
    return unless beneficiaire

    evaluations.update_all(beneficiaire_id: beneficiaire.id)
  end

  private

  def beneficiaire_le_plus_ancien
    Beneficiaire.where(id: evaluations.select(:beneficiaire_id))
                .par_date_creation_asc
                .first
  end
end
