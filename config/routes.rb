Rails.application.routes.draw do
  devise_for :administrateurs, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
