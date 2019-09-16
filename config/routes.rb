Rails.application.routes.draw do
  devise_for :comptes, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    resources :evaluations, only: [:create, :show]
    resources :evenements
  end
end
