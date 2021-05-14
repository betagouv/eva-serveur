# frozen_string_literal: true

class CompteMailer < ApplicationMailer
  def nouveau_compte
    @campagne = params[:campagne]
    @compte = @campagne.compte
    mail(to: @campagne.compte.email,
         subject: t('.objet', structure: @compte.structure.nom))
  end
end
