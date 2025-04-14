# frozen_string_literal: true

class RelanceUtilisateurPourNonActivationJob < ApplicationJob
  queue_as :default

  def perform(compte_id)
    compte = Compte.find_by id: compte_id
    return if compte.blank? || compte.structure.blank?

    return unless compte_sans_evaluations?(compte)

    CompteMailer.with(compte: compte).relance.deliver_now
  end

  def compte_sans_evaluations?(compte)
    Campagne.left_outer_joins(:evaluations)
            .where(compte: compte)
            .group(:compte_id)
            .pluck("COUNT(evaluations.id)")
            .all?(&:zero?)
  end
end
