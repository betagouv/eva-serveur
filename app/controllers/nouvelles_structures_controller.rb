class NouvellesStructuresController < ApplicationController
  layout "active_admin_logged_out"
  helper ::ActiveAdmin::ViewHelpers

  def show
    @compte = Compte.new
    @compte.build_structure type: StructureLocale.name
  end

  def create
    @compte = Compte.new compte_parametres
    valide_siret_obligatoire
    return render :show unless @compte.structure.errors.empty?

    if verify_recaptcha(model: @compte) && @compte.save
      envoie_emails
      sign_in @compte
      redirect_to admin_dashboard_path, notice: I18n.t("nouvelle_structure.bienvenue")
    else
      render :show
    end
  end

  private

  def compte_parametres
    parametres = params.require(:compte).permit!.to_h
    parametres.merge!(statut_validation: :acceptee, role: "admin")
    parametres[:structure_attributes].merge!(type: StructureLocale.name)
    parametres
  end

  def valide_siret_obligatoire
    return if @compte.structure.nil?

    if @compte.structure.siret.blank?
      @compte.structure.errors.add(:siret, :blank)
      @compte.errors.add(:base, :structure_invalide)
    end
  end

  def envoie_emails
    StructureMailer.with(compte: @compte, structure: @compte.structure)
                   .nouvelle_structure
                   .deliver_later
  end
end
