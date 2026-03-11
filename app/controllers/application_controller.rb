class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :configure_permitted_parameters, if: :active_admin_devise_controller?
  before_action :bloque_acces_si_compte_en_attente
  helper_method :annulation_formulaire

  def current_ability
    @current_ability ||= Ability.new(current_compte)
  end

  def verifie_validation_necessaire
    return if active_admin_devise_controller?

    return if current_compte.validation_acceptee?

    redirect_to admin_validation_necessaire_path
  end

  def verifie_compte_connecte
    return if current_compte.present?

    redirect_to new_compte_session_path
  end

  private

  def bloque_acces_si_compte_en_attente
    return if active_admin_devise_controller?
    return if current_compte.blank?
    return unless current_compte.acces_plateforme_bloque?

    zone = zone_du_chemin(request.path)
    return if current_ability.can?(:access_zone, zone)

    redirect_to admin_dashboard_path
  end

  def zone_du_chemin(path)
    return :admin if path.start_with?("/admin")
    return :inscription if path.start_with?("/inscription")

    :plateforme
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[structure_id prenom nom telephone])
  end

  def active_admin_devise_controller?
    is_a? ActiveAdmin::Devise::Controller
  end

  def annulation_formulaire(form)
    if resource.new_record?
      form.cancel_link({ action: "index" }, {}, { class: "cancel bouton-annuler" })
    else
      form.cancel_link({ action: "show" }, {}, { class: "cancel bouton-annuler" })
    end
  end
end
