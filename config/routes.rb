Rails.application.routes.draw do
  devise_for :comptes, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get '/', to: redirect('/admin')

  namespace :api do
    resources :evaluations, only: [:create, :show]
    resources :questionnaires, only: [:show]
    resources :evenements
  end
end
