# frozen_string_literal: true

class StructureMailer < ApplicationMailer
  def nouvelle_structure
    @structure = params[:structure]
    @compte = params[:compte]

    mail(to: @compte.email,
         subject: t('.objet', structure: @structure.display_name))
  end
end
