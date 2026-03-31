# frozen_string_literal: true

class CreationCompteDepuisInvitationService
  Resultat = Struct.new(:compte, :succes, keyword_init: true)

  def initialize(invitation:, parametres_compte:, verification_recaptcha:)
    @invitation = invitation
    @parametres_compte = parametres_compte
    @verification_recaptcha = verification_recaptcha
  end

  def appeler
    compte = construire_compte
    compte.assigne_preinscription
    return Resultat.new(compte: compte, succes: false) unless @verification_recaptcha.call(compte)
    return Resultat.new(compte: compte, succes: false) unless compte.save

    @invitation.marquer_acceptee!(compte)
    Resultat.new(compte: compte, succes: true)
  end

  private

  def construire_compte
    attrs = @parametres_compte.to_h.symbolize_keys
    email_saisi = attrs[:email].to_s.strip.downcase
    attrs[:email] = email_saisi.presence || @invitation.email_destinataire.to_s.strip.downcase
    Compte.new(attrs.merge(attributs_invitation))
  end

  def attributs_invitation
    siret = @invitation.structure&.siret
    {
      structure_id: @invitation.structure_id,
      role: @invitation.role_pour_compte,
      statut_validation: invitant_autorise_validation_directe? ? :acceptee : :en_attente,
      siret_pro_connect: siret.present? ? siret.to_s : nil
    }
  end

  def invitant_autorise_validation_directe?
    @invitation.invitant.au_moins_admin?
  end
end
