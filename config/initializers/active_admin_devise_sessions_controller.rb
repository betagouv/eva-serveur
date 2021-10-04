class ActiveAdmin::Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    if !resource.confirmed?
      set_flash_message! :notice, :"signed_in_but_#{resource.inactive_message}"
    else
      set_flash_message!(:notice, :signed_in)
    end
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end
end
