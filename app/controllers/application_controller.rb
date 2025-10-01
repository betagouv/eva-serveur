class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :configure_permitted_parameters, if: :active_admin_devise_controller?
  helper_method :annulation_formulaire

  def current_ability
    @current_ability ||= Ability.new(current_compte)
  end

  def verifie_validation_necessaire
    return if active_admin_devise_controller?

    return if current_compte.validation_acceptee?

    redirect_to admin_validation_necessaire_path
  end

  private

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
