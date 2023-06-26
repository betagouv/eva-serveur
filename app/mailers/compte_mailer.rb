# frozen_string_literal: true

class CompteMailer < ApplicationMailer
  def nouveau_compte
    @compte = params[:compte]
    @admins = ["mon admin", "mon autre admin"] ## @compte.find_admins
    mail(to: @compte.email,
         subject: t('.objet', structure: @compte.structure.display_name))
  end

  def alerte_admin
    @compte = params[:compte]
    @compte_admin = params[:compte_admin]
    mail(to: @compte_admin.email,
         subject: t('.objet', structure: @compte.structure.display_name))
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

  def comptes_a_autoriser
    @comptes = params[:comptes]
    @compte_admin = params[:compte_admin]
    mail(
      to: @compte_admin.email,
      subject: t('.objet')
    )
  end
end
