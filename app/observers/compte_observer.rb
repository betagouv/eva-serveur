# frozen_string_literal: true

class CompteObserver < ActiveRecord::Observer
  def after_create(compte)
    return if compte.superadmin?

    programme_email_relance(compte)
    envoie_emails(compte)
  end

  private

  def envoie_emails(compte)
    CompteMailer.with(compte: compte).nouveau_compte.deliver_later

    compte.find_admins.each do |admin|
      CompteMailer.with(compte: compte, compte_admin: admin)
                  .alerte_admin
                  .deliver_later
    end
  end

  def programme_email_relance(compte)
    RelanceUtilisateurPourNonActivationJob
      .set(wait: Compte::DELAI_RELANCE_NON_ACTIVATION)
      .perform_later(compte.id)
  end
end
