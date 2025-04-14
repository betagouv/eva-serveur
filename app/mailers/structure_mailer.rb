# frozen_string_literal: true

class StructureMailer < ApplicationMailer
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
