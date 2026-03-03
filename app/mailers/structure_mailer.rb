class StructureMailer < ApplicationMailer
  def invitation_structure
    @invitation = params[:invitation]
    @invitant = @invitation.invitant
    @structure = @invitation.structure
    @message_personnalise = @invitation.message_personnalise
    @lien_invitation = new_compte_registration_url(invitation_token: @invitation.token)

    mail(
      to: @invitation.email_destinataire,
      subject: t(".objet", structure: @structure.display_name)
    )
  end

  def nouvelle_structure
    @structure = params[:structure]
    @compte = params[:compte]

    mail(to: @compte.email,
         subject: t(".objet", structure: @structure.display_name))
  end

  def relance_creation_campagne
    @compte_admin = params[:compte_admin]

    mail(
      to: @compte_admin.email,
      subject: t(".objet", prenom: @compte_admin.prenom)
    )
  end
end
