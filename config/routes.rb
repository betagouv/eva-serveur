Rails.application.routes.draw do
  devise_config = ActiveAdmin::Devise.config
  devise_config[:controllers][:omniauth_callbacks] = 'admin/omniauth_callbacks'
  devise_for :comptes, devise_config

  ActiveAdmin.routes(self)

  get '/', to: redirect('/admin')

  namespace :api do
    resources :evaluations, only: [:create, :show]
    resources :evenements
  end
end
