# frozen_string_literal: true

class StructureMailer < ApplicationMailer
  helper :application

  def nouvelle_structure
    @structure = params[:structure]
    @compte = params[:compte]

    mail(to: @compte.email,
         subject: t('.objet', structure: @structure.nom))
  end
end
