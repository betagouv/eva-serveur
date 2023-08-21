# frozen_string_literal: true

module Comptes
  module EnvoieEmails
    extend ActiveSupport::Concern

    included do
      after_commit :after_commit, on: %i[create update]
    end

    private

    def after_commit
      return if email_bienvenue_envoye? || email_non_confirme? || structure.blank? || superadmin?

      envoie_bienvenue(self)
      alerte_admins(self) if validation_en_attente?
      programme_email_relance(self)
      update(email_bienvenue_envoye: true)
    end

    def envoie_bienvenue(compte)
      CompteMailer.with(compte: compte).nouveau_compte.deliver_later
    end

    def alerte_admins(compte)
      compte.find_admins.each do |admin|
        CompteMailer.with(compte: compte, compte_admin: admin)
                    .alerte_admin
                    .deliver_later
      end
    end

    def programme_email_relance(compte)
      return unless compte.structure.instance_of?(StructureLocale)

      RelanceUtilisateurPourNonActivationJob
        .set(wait: Compte::DELAI_RELANCE_NON_ACTIVATION)
        .perform_later(compte.id)
    end
  end
end
