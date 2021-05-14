# frozen_string_literal: true

class CampagneMailer < ApplicationMailer
  def relance
    @campagne = params[:campagne]
    @compte = @campagne.compte
    structure = @compte.structure
    @cible_evaluation = structure.cible_evaluation
    @nombre_collegue = @compte.nombre_collegue

    mail(
      to: @campagne.compte.email,
      subject: t('.objet', prenom: @compte.prenom)
    )
  end
end
