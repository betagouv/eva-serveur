class RelanceUtilisateurPourNonActivationJob < ApplicationJob
  queue_as :default

  def perform(compte_id)
    compte = Compte.find_by id: compte_id
    return if compte.blank? || compte.structure.blank?

    return if au_moins_une_evaluation?(compte)

    CompteMailer.with(compte: compte).relance.deliver_now
  end

  def au_moins_une_evaluation?(compte)
    Evaluation.joins(:campagne).exists?(campagnes: { compte_id: compte.id })
  end
end
