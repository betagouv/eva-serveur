# frozen_string_literal: true

class CompteMailer < ApplicationMailer
  def nouveau_compte
    @compte = params[:compte]
    mail(to: @compte.email,
         subject: t('.objet', structure: @compte.structure.nom))
  end

  def relance
    @compte = params[:compte]
    structure = @compte.structure
    @cible_evaluation = structure.cible_evaluation
    @effectif = structure.effectif

    mail(
      to: @compte.email,
      subject: t('.objet', prenom: @compte.prenom)
    )
  end
end
