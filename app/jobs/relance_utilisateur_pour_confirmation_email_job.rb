# frozen_string_literal: true

class RelanceUtilisateurPourConfirmationEmailJob < ApplicationJob
  queue_as :default

  def perform
    return if comptes_non_confirmes.blank?

    comptes_non_confirmes.each do |compte|
      compte.send_confirmation_instructions.deliver
    end
  end

  def comptes_non_confirmes
    Compte.where(confirmed_at: nil)
  end
end
