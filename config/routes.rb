Rails.application.routes.draw do
  devise_for :comptes, ActiveAdmin::Devise.config
  get '/admin', to: redirect('/admin/dashboard')

  ActiveAdmin.routes(self)

  get '/', to: redirect('/admin/dashboard')

  resource :nouvelle_structure, only: [:create, :show]

  namespace :api do
    resources :evaluations, only: [:create, :show, :update]
    resources :questionnaires, only: [:show]
    resources :evenements
  end
end
