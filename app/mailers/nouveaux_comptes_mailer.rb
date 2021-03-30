# frozen_string_literal: true

class NouveauxComptesMailer < ApplicationMailer
  helper :application

  def email_nouveau_compte
    @campagne = params[:campagne]
    @compte = @campagne.compte
    mail(to: @campagne.compte.email,
         subject: t('.objet', structure: @compte.structure.nom))
  end
end
