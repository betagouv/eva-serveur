# frozen_string_literal: true

class EnvoiInvitationService
  Result = Struct.new(:success?, :invitation, :error, keyword_init: true) do
    def email
      invitation&.email_destinataire
    end
  end

  def initialize(structure:, invitant:, email:, message: "", role: nil)
    @structure = structure
    @invitant = invitant
    @email = email.to_s.strip
    @message = message.to_s.strip
    @role_param = role
  end

  def call
    return Result.new(success?: false, error: :invitation_non_autorisee) unless autorise?
    return Result.new(success?: false, error: :email_invalide) unless email_valide?

    invitation = @structure.invitations.create!(
      email_destinataire: @email,
      invitant: @invitant,
      message_personnalise: @message,
      role: role_pour_invitation
    )
    StructureMailer.with(invitation: invitation).invitation_structure.deliver_later
    Result.new(success?: true, invitation: invitation)
  end

  private

  def autorise?
    return true if @invitant.superadmin?
    return false if @invitant.structure.blank?

    structure_ids = @invitant.admin? ? @invitant.structure.subtree_ids : [ @invitant.structure_id ]
    compte_role_autorise = @invitant.admin? || @invitant.conseiller?
    compte_role_autorise && structure_ids.include?(@structure.id)
  end

  def email_valide?
    @email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  def role_pour_invitation
    if @invitant.au_moins_admin?
      @role_param.presence || Compte::ROLE_PAR_DEFAUT
    else
      Compte::ROLE_PAR_DEFAUT
    end
  end
end
