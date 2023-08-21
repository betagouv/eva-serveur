# frozen_string_literal: true

module Comptes
  module EnvoieEmails
    extend ActiveSupport::Concern

    included do
      after_commit :after_commit_on_create, on: :create
    end

    private

    def after_commit_on_create
      return if superadmin?

      programme_email_relance(self)
      envoie_emails(self)
    end

    def envoie_emails(compte)
      CompteMailer.with(compte: compte).nouveau_compte.deliver_later

      alerte_admins(compte) if compte.validation_en_attente?
    end

    def programme_email_relance(compte)
      return unless compte.structure.instance_of?(StructureLocale)

      RelanceUtilisateurPourNonActivationJob
        .set(wait: Compte::DELAI_RELANCE_NON_ACTIVATION)
        .perform_later(compte.id)
    end

    def alerte_admins(compte)
      compte.find_admins.each do |admin|
        CompteMailer.with(compte: compte, compte_admin: admin)
                    .alerte_admin
                    .deliver_later
      end
    end
  end
end
