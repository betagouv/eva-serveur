class ActiveAdmin::Devise::SessionsController
  before_action :check_compte_confirmation, only: :create

  def create
    self.resource = warden.authenticate!(auth_options)
    if !resource.confirmed?
      set_flash_message! :alert, :"signed_in_but_#{resource.inactive_message}"
    else
      set_flash_message!(:notice, :signed_in)
    end
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

private

  def check_compte_confirmation
    compte = Compte.find_by_email(params[:compte][:email])
    return flash.now[:alert] if compte.blank?
    redirect_to new_compte_confirmation_path unless compte.active_for_authentication?
  end
end
